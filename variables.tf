variable "region" {
  type    = string
  default = "us-east-1"
}


variable "vpc_1_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets_vpc_1" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets_vpc_1" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "vpc_2_cidr_range" {
  type    = string
  default = "172.0.0.0/16"
}

variable "private_subnets_vpc_2" {
  type    = list(string)
  default = ["172.0.1.0/24", "172.0.2.0/24"]
}

variable "public_subnets_vpc_2" {
  type    = list(string)
  default = ["172.0.101.0/24", "172.0.102.0/24"]
}


variable "ami_id" {
  type    = string
  default = "ami-05b10e08d247fb927"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "alb_name" {
# Declaring input variable for module
  type = string
  default = "vpc-1-alb"
}

variable "lb_target_group_name" {
# Declaring input variable for module
  type = string
  default = "vpc1-tg"
}

variable "key_name" {
# Declaring input variable for module
  type = string
  default = "l2-prod"
}

