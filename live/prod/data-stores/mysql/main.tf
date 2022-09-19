############################################################################

provider "aws" {
        region = "us-east-1"
}

############################################################################

resource "aws_db_instance" "example" {
    identifier_prefix   = "prod-terraform-up-and-running"
    engine              = "mysql"
    allocated_storage   = 10
    instance_class      = "db.t2.micro"
    db_name             = "example_database"
    username            = "admin"
    password            = local.db_pass.password
    skip_final_snapshot = true
}

data "aws_secretsmanager_secret_version" "db_password" {
    # Fill in the name you gave to your secret
    secret_id = "mysql_password_prod"
}

locals {
  db_pass = jsondecode(
    data.aws_secretsmanager_secret_version.db_password.secret_string
  )
}
############################################################################

terraform {
    backend "s3" {
    # Поменяйте это на имя своего бакета!
    bucket = "terraform-state-brickman"
    key = "prod/datastores/mysql/terraform.tfstate"
    region = "us-east-1"
    #Замените это именем своей таблицы DynamoDB!
    dynamodb_table = "terraform-state-brickman"
    encrypt = true
    }
}

############################################################################