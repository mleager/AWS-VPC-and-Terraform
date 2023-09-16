variable "env_code" {
  type = string
}

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

variable "password" {
  default = local.pass
}
