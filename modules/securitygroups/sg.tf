# Security Group for Application Load Balancers (ALB)
resource "aws_security_group" "alb_sg" {
# Defining an AWS resource
  vpc_id = var.vpc_id

  # Allow HTTP traffic from anywhere (0.0.0.0/0) to the ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic from the ALB
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Security group for application instances
resource "aws_security_group" "instance_sg" {
# Defining an AWS resource
  vpc_id = var.vpc_id

  # Allow HTTP traffic from the ALB only
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }


  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the RDS database
resource "aws_security_group" "rds_sg" {
# Defining an AWS resource
  name   = "rds-security-group"
  vpc_id = var.vpc_id

  # Allow MySQL traffic only from the application instances
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.instance_sg.id]
  }

  # Allow outbound traffic only within the VPC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.vpc_cidr
  }

  tags = {
    Name = "rds-mysql-sg"
  }
}


resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg"
  description = "Allow inbound traffic for Aurora DB"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this to your IP range for security
    security_groups = [aws_security_group.instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.vpc_cidr
  }
}