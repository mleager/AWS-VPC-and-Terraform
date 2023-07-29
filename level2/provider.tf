terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.9.0"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
    bucket         = "tf-state-mentorship"
    key            = "level2.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-remote-state-locking"
  }
}

provider "aws" {
  region = "us-east-1"
}
