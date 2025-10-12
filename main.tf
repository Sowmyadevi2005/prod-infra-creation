#############################################
# Common Tags - applied to supported resources
#############################################
locals {
  common_tags = {
    Project     = "L2-Track"
    Environment = "prod"
  }
}
#############################################
# Data Source: Availability Zones
#############################################
data "aws_availability_zones" "azs" {}

#############################################
# VPC 1 - Application Layer Network
#############################################
module "vpc_1" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-1"
  cidr = var.vpc_1_cidr_range

  azs             = slice(data.aws_availability_zones.azs.names, 0, 3)
  private_subnets = var.private_subnets_vpc_1
  public_subnets  = var.public_subnets_vpc_1

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  tags = local.common_tags
}

#############################################
# Security Groups - VPC 1
#############################################
module "security_groups_vpc1" {
  source = "./modules/securitygroups"
  vpc_id = module.vpc_1.vpc_id
}

#############################################
# Load Balancer (ALB) - VPC 1
#############################################
module "loadbalancer" {
  source               = "./modules/loadbalancer"
  vpc_id               = module.vpc_1.vpc_id
  public_subnets       = module.vpc_1.public_subnets
  alb_sg_id            = module.security_groups_vpc1.alb_sg_id
  alb_name             = var.alb_name
  lb_target_group_name = var.lb_target_group_name

}

#############################################
# Auto Scaling Group - VPC 1
#############################################
module "autoscaling" {
  source              = "./modules/autoscaling"
  instance_sg         = module.security_groups_vpc1.instance_sg_id
  target_group_arn    = module.loadbalancer.target_group_arn
  private_app_subnets = module.vpc_1.private_subnets
  bastion_sg = module.security_groups_vpc1.bastion_sg_id
  bastion_subnet = module.vpc_1.public_subnets[0]
  key_name            = var.key_name

}

#############################################
# VPC 2 - Database Layer Network
#############################################
module "vpc_2" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-2"
  cidr = var.vpc_2_cidr_range

  azs             = slice(data.aws_availability_zones.azs.names, 0, 2)
  private_subnets = var.private_subnets_vpc_2
  public_subnets  = var.public_subnets_vpc_2

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  tags = local.common_tags
}

#############################################
# Security Groups - VPC 2
#############################################
module "security_groups_vpc2" {
  source                     = "./modules/securitygroups"
  vpc_id                     = module.vpc_2.vpc_id
  vpc1_private_subnets_cidrs = module.vpc_1.private_subnets_cidr_blocks

}

#############################################
# Aurora Database Cluster - VPC 2
#############################################
module "aurora_db" {
  source = "./modules/aurora-db"

  cluster_identifier = "aurora-cluster-2"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.04.1"
  master_username    = "admin"
  master_password    = "ChangeMe123!"
  database_name      = "appdb"

  vpc_id             = module.vpc_2.vpc_id
  subnet_ids         = module.vpc_2.private_subnets
  security_group_ids = [module.security_groups_vpc2.aurora_sg_id]

  instance_class = "db.r6g.large"
  instances      = 2

  backup_retention_period      = 7
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "sun:05:00-sun:06:00"

  tags = local.common_tags
}

#############################################
# VPC Peering Connection
#############################################
resource "aws_vpc_peering_connection" "app_to_db" {
  vpc_id      = module.vpc_1.vpc_id
  peer_vpc_id = module.vpc_2.vpc_id
  auto_accept = true

  tags = merge(local.common_tags, {
    Name = "app-db-peering"
  })
}

#############################################
# Routes: App → DB
#############################################
resource "aws_route" "app_to_db_route" {
  for_each = { for idx, rtb_id in module.vpc_1.private_route_table_ids : idx => rtb_id }

  route_table_id            = each.value
  destination_cidr_block    = var.vpc_2_cidr_range
  vpc_peering_connection_id = aws_vpc_peering_connection.app_to_db.id
}

#############################################
# Routes: DB → App
#############################################
resource "aws_route" "db_to_app_route" {
  for_each = { for idx, rtb_id in module.vpc_2.private_route_table_ids : idx => rtb_id }

  route_table_id            = each.value
  destination_cidr_block    = var.vpc_1_cidr_range
  vpc_peering_connection_id = aws_vpc_peering_connection.app_to_db.id
}
