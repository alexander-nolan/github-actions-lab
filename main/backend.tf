terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket019179"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
} 