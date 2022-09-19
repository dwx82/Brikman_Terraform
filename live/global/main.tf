provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-state-brickman"
    
    # Предотвращаем случайное удаление этого бакета S3
    lifecycle {
        prevent_destroy = true
    }

    versioning {
        enabled = true
    }

    # Включаем шифрование по умолчанию на стороне сервера
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

#Нужно создать таблицу DynamoDB, которая будет использоваться для блокирования. DynamoDB — это
#распределенное хранилище типа «ключ — значение» от Amazon.
resource "aws_dynamodb_table" "terraform_locks" {
    name         = "terraform-state-brickman"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"
    
    attribute {
        name = "LockID"
        type = "S"
    }
}

############################################################################

terraform {
    backend "s3" {
    # Поменяйте это на имя своего бакета!
    bucket = "terraform-state-brickman"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
    #Замените это именем своей таблицы DynamoDB!
    dynamodb_table = "terraform-state-brickman"
    encrypt = true
    }
}