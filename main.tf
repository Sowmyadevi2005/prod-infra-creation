provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "azs" {}

# VPC 1
module "vpc_1" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-1"
  cidr = var.vpc_1_cidr_range

  azs             = slice(data.aws_availability_zones.azs.names, 0, 3)
  private_subnets = var.private_subnets_vpc_1
  public_subnets  = var.public_subnets_vpc_1

  enable_nat_gateway         = true
  #enable_vpn_gateway         = true
  single_nat_gateway         = false
  one_nat_gateway_per_az     = true

  tags = {
    Terraform   = "true"
    Environment = "prod-VPC-1"
  }
}

module "security_groups" {
# Calling a reusable module
  source   = "./modules/securitygroups"
  vpc_id   = module.vpc_1.vpc_id
  vpc_cidr = [var.vpc_1_cidr_range]
}

module "loadbalancer" {
# Calling a reusable module
  source               = "./modules/loadbalancer"
  vpc_id               = module.vpc_1.vpc_id
  public_subnets       = module.vpc_1.public_subnets
  alb_sg_id            = module.security_groups.alb_sg_id
  alb_name             = var.alb_name
  lb_target_group_name = var.lb_target_group_name
}

module "autoscaling" {
  source              = "./modules/autoscaling"
  instance_sg         = module.security_groups.instance_sg_id
  target_group_arn    = module.loadbalancer.target_group_arn
  private_app_subnets = module.vpc_1.private_subnets
  key_name            = var.key_name
}


resource "aws_network_interface" "eni" {
  subnet_id       = module.vpc_1.private_subnets[0]
  private_ips     = ["10.0.1.100"]
  security_groups = [module.security_groups.instance_sg_id]

  tags = {
    Name = "eni-for-db-access"
  }
}


# VPC 2
module "vpc_2" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-2"
  cidr = var.vpc_2_cidr_range

  azs             = slice(data.aws_availability_zones.azs.names, 0, 2)
  private_subnets = var.private_subnets_vpc_2
  public_subnets  = var.public_subnets_vpc_2

  enable_nat_gateway         = true
  #enable_vpn_gateway         = true
  single_nat_gateway         = false
  one_nat_gateway_per_az     = true

  tags = {
    Terraform   = "true"
    Environment = "prod-VPC-2"
  }
}

module "aurora_db" {
  source = "./modules/aurora-db"

  cluster_identifier      = "aurora-cluster-2"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.1"
  master_username         = "admin"
  master_password         = "ChangeMe123!"
  database_name           = "appdb"

  vpc_id                  = module.vpc_2.vpc_id
  subnet_ids      = module.vpc_2.private_subnets
  security_group_ids      = [module.vpc_2.default_security_group_id]

  instance_class          = "db.r6g.large"
  instances               = 2

  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"
  preferred_maintenance_window = "sun:05:00-sun:06:00"

  tags = {
    Environment = "dev"
    Project     = "L2-Track"
  }
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "app_to_db" {
  vpc_id      = module.vpc_1.vpc_id
  peer_vpc_id = module.vpc_2.vpc_id
  auto_accept = true

  tags = {
    Name = "app-db-peering"
  }
}

# Routes from App VPC to DB VPC
resource "aws_route" "app_to_db_route" {
  for_each = { for idx, rtb_id in module.vpc_1.private_route_table_ids : idx => rtb_id }

  route_table_id             = each.value
  destination_cidr_block     = var.vpc_2_cidr_range
  vpc_peering_connection_id  = aws_vpc_peering_connection.app_to_db.id
}

# Routes from DB VPC to App VPC
resource "aws_route" "db_to_app_route" {
  for_each = { for idx, rtb_id in module.vpc_2.private_route_table_ids : idx => rtb_id }

  route_table_id             = each.value
  destination_cidr_block     = var.vpc_1_cidr_range
  vpc_peering_connection_id  = aws_vpc_peering_connection.app_to_db.id
}
