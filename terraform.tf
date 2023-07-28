terraform {
  backend "s3" {
    bucket = "tf-state-mentorship"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "tf-remote-state-locking"
  }
}
