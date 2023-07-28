resource "aws_s3_bucket" "terraform_state" {
  bucket = "tf-state-mentorship"

  tags = {
    Name        = "TF State"
  }
}

resource "aws_s3_object" "state_file" {
  bucket = "tf-state-mentorship"
  key = "terraform.tfstate"
  source = "./terraform.tfstate"
}

resource "aws_dynamodb_table" "state_locking" {
  name     = "tf-remote-state-locking"
  hash_key = "lockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "lockID"
    type = "S"
  }
}
