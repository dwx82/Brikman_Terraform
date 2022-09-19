############################################################################

provider "aws" {
  region = "us-east-1"
}

############################################################################

module "webserver_cluster" {
  source = "/Users/vadimanpilogov/github/Brikman_Terraform/Brikman_Terraform/modules/services/webserver-cluster"

  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "terraform-state-brickman"
  db_remote_state_key    = "prod/datastores/mysql/terraform.tfstate"
  instance_type          = "t2.micro"
  min_size               = 2
  max_size               = 10
}

############################################################################
/*
Первый ресурс aws_autoscaling_schedule используется
для увеличения количества серверов до десяти в утреннее
время (в параметре recurrence используется синтаксис cron,
поэтому "09***" означает «в 9 утра каждый день»), а второй
уменьшает этот показатель на ночь ("017***" значит «в 5
вечера каждый день»).
*/

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name  = "scale-out-duringbusiness-hours"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 4
  recurrence             = "0 9 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"
  /*
  Для обращения к выходным переменным модуля используется следующий синтаксис:
  module.<MODULE_NAME>.<OUTPUT_NAME>
  */
  autoscaling_group_name = module.webserver_cluster.asg_name

}

############################################################################

terraform {
  backend "s3" {
    # Поменяйте это на имя своего бакета!
    bucket = "terraform-state-brickman"
    key    = "prod/services/webservercluster/terraform.tfstate"
    region = "us-east-1"
    #Замените это именем своей таблицы DynamoDB!
    dynamodb_table = "terraform-state-brickman"
    encrypt        = true
  }
}

