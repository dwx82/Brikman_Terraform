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
  instance_type          = "t2.micro"
  min_size               = 2
  max_size               = 2
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id
  from_port         = 12345
  to_port           = 12345
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
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
