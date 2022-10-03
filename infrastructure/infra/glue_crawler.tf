resource "aws_glue_catalog_database" "censo_db" {
  name = "dl_censo_ed_superior_bronze"
}

resource "aws_glue_crawler" "censo_bronze_crawler" {
  database_name = aws_glue_catalog_database.censo_db.name
  name          = "censo_bronze_crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://censo-ed-superior-bronze/"
  }
}
