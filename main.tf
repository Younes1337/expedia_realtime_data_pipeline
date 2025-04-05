# Provider configurations
provider "aws" {
  region = "us-east-1"
}

provider "confluent" {
  cloud  = "aws"
  region = "us-east-1"
}

provider "snowflake" {
  username = var.snowflake_username
  password = var.snowflake_password
  account  = var.snowflake_account
  region   = "us-east-1"
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}

# Confluent resources
resource "confluent_environment" "prod" {
  display_name = "prod"
}

resource "confluent_kafka_cluster" "example" {
  display_name = "example-cluster"
  availability = "single-zone"
  project      = "<your_project_id>"
  region       = "us-east-1"
  cloud        = "aws"
  environment {
    id = confluent_environment.prod.id
  }
}

resource "confluent_kafka_topic" "flink_topic" {
  cluster_id = confluent_kafka_cluster.example.id
  topic_name = "flink_topic"
  partitions = 3
  config = {
    "cleanup.policy" = "delete"
    "retention.ms"   = "604800000"
  }
}

resource "confluent_kafka_topic" "snowflake_topic" {
  cluster_id = confluent_kafka_cluster.example.id
  topic_name = "snowflake_topic"
  partitions = 3
  config = {
    "cleanup.policy" = "delete"
    "retention.ms"   = "604800000"
  }
}

resource "confluent_kafka_topic" "databricks_topic" {
  cluster_id = confluent_kafka_cluster.example.id
  topic_name = "databricks_topic"
  partitions = 3
  config = {
    "cleanup.policy" = "delete"
    "retention.ms"   = "604800000"
  }
}

# FlinkSQL resources
resource "flink_cluster" "example" {
  name       = "example-cluster"
  region     = "us-east-1"
  job_manager = {
    memory = "1024m"
    cpu    = 1
  }
  task_manager = {
    memory = "2048m"
    cpu    = 2
    slots  = 2
  }
}

# Snowflake resources
resource "snowflake_database" "travel" {
  name = "TRAVEL"
}

resource "snowflake_schema" "travel_schema" {
  database = snowflake_database.travel.name
  name     = "TRAVEL_SCHEMA"
}

resource "snowflake_table" "travel_data" {
  database = snowflake_database.travel.name
  schema   = snowflake_schema.travel_schema.name
  name     = "TRAVEL_DATA"

  column {
    name = "icao24"
    type = "VARCHAR"
  }

  column {
    name = "callsign"
    type = "VARCHAR"
  }

  column {
    name = "origin_country"
    type = "VARCHAR"
  }

  column {
    name = "event_time"
    type = "VARCHAR"
  }

  column {
    name = "longitude"
    type = "DOUBLE"
  }

  column {
    name = "latitude"
    type = "DOUBLE"
  }

  column {
    name = "altitude"
    type = "DOUBLE"
  }

  column {
    name = "speed"
    type = "DOUBLE"
  }

  column {
    name = "heading"
    type = "DOUBLE"
  }

  column {
    name = "on_ground"
    type = "BOOLEAN"
  }

  column {
    name = "rowtime"
    type = "TIMESTAMP"
  }
}

# Databricks resources
resource "databricks_cluster" "example" {
  cluster_name            = "example-cluster"
  spark_version           = "7.3.x-scala2.12"
  node_type_id            = "i3.xlarge"
  autotermination_minutes = 20
  autoscale {
    min_workers = 1
    max_workers = 3
  }
}

# Delta Lake configuration for Databricks
resource "databricks_sql_endpoint" "delta_lake_endpoint" {
  name = "delta-lake-endpoint"
  cluster_size = "Large"
}

resource "databricks_sql_endpoint_configuration" "delta_lake_config" {
  endpoint_id = databricks_sql_endpoint.delta_lake_endpoint.id
  configuration = jsonencode({
    "data_source" = "databricks_delta"
    "database"    = "deltalake_db"
    "location"    = "s3a://deltalake-bucket/"
  })
}

# AWS S3 resources
resource "aws_s3_bucket" "iceberg_bucket" {
  bucket = "iceberg-external-volume"
}

resource "aws_s3_bucket" "deltalake_bucket" {
  bucket = "deltalake-bucket"
}