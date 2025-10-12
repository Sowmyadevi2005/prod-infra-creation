# ALB security group ID
variable "alb_sg_id" {
  type = string
}

# VPC ID where the ALB is deployed
variable "vpc_id" {
  type = string
}

# Public subnet IDs for ALB deployment
variable "public_subnets" {
  type = list(string)
}

# Name of the Application Load Balancer
variable "alb_name" {
  type = string
}

# Name of the target group associated with the ALB
variable "lb_target_group_name" {
  type = string
}
