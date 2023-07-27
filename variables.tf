
variable "ami" {
  type    = string
  default = "ami-04823729c75214919"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "iam_instance_profile" {
  type    = string
  default = "EC2FullAccess"
}

variable "key_name" {
  type    = string
  default = "tf-example"
}

variable "public_availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "private_availability_zones" {
  type    = list(string)
  default = ["us-east-1c", "us-east-1d"]
}

variable "az" {
  type = map(string)
  default = {
    "1a" = "us-east-1a"
    "1b" = "us-east-1b"
    "1c" = "us-east-1c"
    "1d" = "us-east-1d"
    "1e" = "us-east-1e"
    "1f" = "us-east-1f"
  }
}