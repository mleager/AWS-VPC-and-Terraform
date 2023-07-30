terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.9.0"
    }
  }
  required_version = ">= 1.2.0"

  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}
