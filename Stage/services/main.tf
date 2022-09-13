############################################################################

provider "aws" {
  region = "us-east-1"
}

############################################################################

module "webserver_cluster" {
  source = "/Users/vadimanpilogov/github/Brikman_Terraform/Brikman_Terraform/modules/services/webserver-cluster"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "terraform-state-brickman"
  db_remote_state_key    = "stage/datastores/mysql/terraform.tfstate"
}

############################################################################

terraform {
  backend "s3" {
    # Поменяйте это на имя своего бакета!
    bucket = "terraform-state-brickman"
    key    = "stage/services/webservercluster/terraform.tfstate"
    region = "us-east-1"
    #Замените это именем своей таблицы DynamoDB!
    dynamodb_table = "terraform-state-brickman"
    encrypt        = true
  }
}
