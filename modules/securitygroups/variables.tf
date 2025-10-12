#############################################
# Variable: vpc_id
# --------------------------------------------
# Description:
#   The ID of the VPC where the security groups
#   will be created. This is used by both VPC 1
#   (Application) and VPC 2 (Database) environments.
#
# Example:
#   vpc-0a1b2c3d4e5f6g7h
#############################################
variable "vpc_id" {
  type        = string
  description = "VPC ID for the security groups"
}

#############################################
# Variable: instance_sg_id
# --------------------------------------------
# Description:
#   Security Group ID of the EC2 instances (App Tier)
#   used to allow inbound traffic to Aurora DB when
#   VPC peering is configured.
#
# Notes:
#   - For VPC 1 SG creation, this can be left null.
#   - For VPC 2 (Aurora DB), use this ID to allow
#     application traffic from App VPC to DB VPC.
#############################################
variable "instance_sg_id" {
  type        = string
  description = "EC2 instance security group ID for Aurora ingress (VPC peering)"
  default     = null  # Optional for VPC 1 SG creation
}

#############################################
# Variable: vpc1_private_subnets_cidrs
# --------------------------------------------
# Description:
#   List of private subnet CIDR ranges from VPC 1.
#   Used by Aurora DB security group to allow inbound
#   MySQL traffic (port 3306) from application servers.
#
# Example:
#   ["10.0.1.0/24", "10.0.2.0/24"]
#############################################
variable "vpc1_private_subnets_cidrs" {
  description = "List of private subnet CIDRs from VPC 1 (for Aurora access)"
  type        = list(string)
  default     = []
}
