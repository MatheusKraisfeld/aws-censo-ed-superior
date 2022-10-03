import csv
import os
import re
import zipfile
from datetime import datetime

import boto3
import pandas as pd
import requests
import unidecode
from airflow import DAG
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator
from airflow.providers.cncf.kubernetes.operators.spark_kubernetes import \
    SparkKubernetesOperator
from airflow.providers.cncf.kubernetes.sensors.spark_kubernetes import \
    SparkKubernetesSensor
from airflow.sensors.python import PythonSensor
from airflow.utils.dates import days_ago
from bs4 import BeautifulSoup
from dateutil.relativedelta import relativedelta
from requests.packages.urllib3.exceptions import InsecureRequestWarning

s3 = boto3.client("s3")
url = "https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados/censo-da-educacao-superior"
bucket_path = "aws-censo-ed-superior"
aws_access_key_id = Variable.get("aws_access_key_id")
aws_secret_access_key = Variable.get("aws_secret_access_key")
glue = boto3.client(
    "glue",
    region_name="us-east-1",
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
)


def download_file(url, full_path, chunk_size=128):
    r = requests.get(url, stream=True, verify=False)
    with open(full_path, "wb") as fd:
        for chunk in r.iter_content(chunk_size=chunk_size):
            fd.write(chunk)


def download_and_unzip(url, save_path):
    if not os.path.exists(save_path):
        os.makedirs(save_path)
    head, tail = os.path.split(url)
    full_path = f"{save_path}/{tail}"
    download_file(url, full_path)
    with zipfile.ZipFile(full_path, "r") as zip_ref:
        dir_path = full_path.replace(".zip", "")
        zip_ref.extractall(dir_path)
    return dir_path


def get_files(url, file_format="zip", years_interval=6):
    r = requests.get(url)
    soup = BeautifulSoup(r.content, "html.parser")
    pattern_to_find = "microdados_censo_da_educacao_superior"
    files = [
        i["href"]
        for i in soup.find_all("a", href=True)
        if i.get("href")
        and i["href"].endswith(f".{file_format}")
        and i["href"].find(pattern_to_find) > -1
    ]
    return filter_files_by_year(files, years_interval)


def filter_files_by_year(files, years_interval):
    years = [
        int(re.search("[0-9]{4}", year).group(0))
        for year in files
        if re.findall("[0-9]{4}", year)
    ]
    range_years = [
        str(year) for year in range(max(years) - (years_interval - 1), max(years) + 1)
    ]
    selected_files = []
    for file in files:
        if any(year in file for year in range_years):
            selected_files = selected_files + [file]
    return selected_files


def upload_directory(path, bucketname):
    for root, dirs, files in os.walk(path):
        for file in files:
            dir_path = unidecode.unidecode(root.replace(" ", "_"))
            s3.upload_file(os.path.join(root, file), bucketname, dir_path + file)


def run_extract():
    files = get_files(url)
    for file in files:
        try:
            today = datetime.today()
            full_path = download_and_unzip(file, f"{today.year}_{today.month}")
            upload_directory(full_path, bucket_path)
        except Exception as e:
            print(e)


def trigger_censo_bronze_crawler_func():
    glue.start_crawler(Name="censo_bronze_crawler")


with DAG(
    "censo_ed_superior_spark_k8s",
    default_args={
        "owner": "Matheus",
        "depends_on_past": False,
        "email": ["matheuskraisfeld@gmail.com.br"],
        "email_on_failure": False,
        "email_on_retry": False,
        "max_active_runs": 1,
    },
    description="ETL Censo Educação Superior",
    schedule_interval="0 0 1 1,7 *",  # 1 de Janeiro e Julho às 00:00
    start_date=days_ago(1),  # 1 dia atrás
    catchup=False,  # Não executa os dias que faltaram
    tags=[
        "spark",
        "kubernetes",
        "censo",
        "educacao_superior",
    ],  # Tags para filtrar no Airflow
) as dag:
    extract = PythonSensor(
        task_id="extract",
        python_callable=run_extract,
        poke_interval=120,
        timeout=1800,
        mode="reschedule",
    )

    csv_to_parquet = SparkKubernetesOperator(
        task_id="csv_to_parquet",
        namespace="airflow",
        application_file="csv_to_parquet.yaml",
        kubernetes_conn_id="kubernetes_default",
        do_xcom_push=True,
    )

    csv_to_parquet_monitor = SparkKubernetesSensor(
        task_id="csv_to_parquet_monitor",
        namespace="airflow",
        application_name="{{ task_instance.xcom_pull(task_ids='csv_to_parquet')['metadata']['name'] }}",
        kubernetes_conn_id="kubernetes_default",
    )

    trigger_censo_bronze_crawler = PythonOperator(
        task_id="trigger_censo_bronze_crawler",
        python_callable=trigger_censo_bronze_crawler_func,
    )

(extract >> csv_to_parquet >> csv_to_parquet_monitor >> trigger_censo_bronze_crawler)
