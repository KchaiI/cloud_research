terraform {
    required_version = "> 1.5.0"

    required_providers {
        aws = {
            source = "hashicorp/aws"
            ersion = "~> 5.0"
        }
    }
}

proviedr "aws" {
    region = var.aws_region
    profile = "default"
}