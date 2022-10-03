from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession

print("***** INICIO *****")

# set conf
conf = (
    SparkConf()
    .set("spark.hadoop.fs.s3a.fast.upload", True)
    .set("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
    .set(
        "spark.hadoop.fs.s3a.aws.credentials.provider",
        "com.amazonaws.auth.EnvironmentVariableCredentialsProvider",
    )
    .set("spark.jars.packages", "org.apache.hadoop:hadoop-aws:2.7.3")
)

print("***** SPARK CONFIG *****")

# apply config
sc = SparkContext(conf=conf).getOrCreate()


if __name__ == "__main__":

    print("***** MAIN *****")

    # init spark session
    spark = SparkSession.builder.appName("csv_to_parquet").getOrCreate()

    spark.sparkContext.setLogLevel("INFO")
    # listar todos os arquivos dentro de bucket_name/year_month 
    # que contenham a extensão .csv e contenham o 
    # prefixo "MICRODADOS_CADASTRO_CURSOS" por exemplo

    # com a lista de arquivos selecionados, ler todos em um único 
    # dataframe e salvar em formato delta na zona bronze
    # do lake particionado por perfil geográfico e área de estudo
    # se existirem essas informações nos dados
    # df = (
    #     spark.read.format("csv")
    #     .options(header="true", inferSchema="true", delimiter=";")
    #     .load("s3a://landing-zone-741358071637/enem/year=2019")
    # )

    # df.printSchema()

    # (
    #     df.write.mode("overwrite")
    #     .format("parquet")
    #     .save("s3a://processing-zone-741358071637/enem/")
    # )
    print(spark)
    print("*********************")
    print("Escrito com sucesso!")
    print("*********************")

    spark.stop()
