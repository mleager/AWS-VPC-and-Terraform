resource "aws_s3_bucket" "remote_state" {
  bucket = "tf-state-mentorship"

  tags = {
    Name = "Remote Backend"
  }
}

resource "aws_dynamodb_table" "state_locking" {
  name         = "tf-remote-state-locking"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
