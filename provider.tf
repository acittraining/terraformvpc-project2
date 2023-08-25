terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
}

#Configure the provider 
provider "aws" {
  region = var.aws_region
}

