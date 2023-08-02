variable "ami" {
  type    = string
  default = "ami-04823729c75214919"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "env_code" {}

variable "vpc_id" {}

variable "private_subnet_id" {}

variable "load_balancer_sg" {}

variable "target_group_arn" {}
