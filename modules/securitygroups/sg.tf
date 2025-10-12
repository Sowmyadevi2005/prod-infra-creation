#############################################
# Security Group for ALB (VPC 1)
# - Allows inbound HTTP traffic from the internet (port 80)
# - Allows all outbound traffic
# - Tagged to identify environment and ownership
#############################################
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security Group for Application Load Balancer"
  vpc_id      = var.vpc_id  # VPC 1 ID passed from root module

  # Inbound rules (HTTP access from Internet)
  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules (allow all)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "alb-sg"
    Project     = "L2-Track"
    Environment = "prod"
    Component   = "ALB"
    ManagedBy   = "Terraform"
  }
}


# Security group for the bastion host (Jump Server)
resource "aws_security_group" "bastion_sg" {
# Defining an AWS resource
  vpc_id = var.vpc_id
  
  # Allow SSH access only from a specific IP (Replace with your actual IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change to your public IP for security
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#############################################
# Security Group for EC2 Instances / Auto Scaling (VPC 1)
# - Allows inbound traffic only from ALB (port 80)
# - Allows all outbound traffic
# - Used by EC2/ASG application servers
#############################################
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security Group for EC2 instances behind ALB"
  vpc_id      = var.vpc_id  # VPC 1

  # Inbound rules (only from ALB security group)
  ingress {
    description    = "Allow HTTP traffic from ALB only"
    from_port      = 80
    to_port        = 80
    protocol       = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Outbound rules (allow all)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "instance-sg"
    Project     = "L2-Track"
    Environment = "prod"
    Component   = "Application-EC2"
    ManagedBy   = "Terraform"
  }
}

#############################################
# Security Group for Aurora Database (VPC 2)
# - Allows inbound MySQL traffic (port 3306)
#   only from App VPC private subnets
# - Allows all outbound traffic
# - Used by Aurora MySQL cluster
#############################################
resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg"
  description = "Security Group for Aurora MySQL Database"
  vpc_id      = var.vpc_id  # VPC 2

  # Inbound rules (MySQL traffic from App VPC)
  ingress {
    description = "Allow MySQL traffic from App VPC private subnets"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.vpc1_private_subnets_cidrs
  }

  # Outbound rules (allow all)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "aurora-sg"
    Project     = "L2-Track"
    Environment = "prod"
    Component   = "Aurora-DB"
    ManagedBy   = "Terraform"
  }
}
