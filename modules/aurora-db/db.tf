# Create a subnet group for Aurora using provided subnet IDs
resource "aws_db_subnet_group" "aurora" { 
  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    {
      Name = "${var.cluster_identifier}-subnet-group"
    },
    var.tags
  )
}

# Create the Aurora RDS cluster with main configuration
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = var.master_password
  database_name           = var.database_name

  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  skip_final_snapshot     = true
  vpc_security_group_ids  = var.security_group_ids

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  tags = merge(
    {
      Name = var.cluster_identifier
    },
    var.tags
  )
}

# Create Aurora cluster instances (reader/writer nodes)
resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = var.instances
  identifier         = "${var.cluster_identifier}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.instance_class
  engine             = var.engine
  engine_version     = var.engine_version
  db_subnet_group_name = aws_db_subnet_group.aurora.name

  tags = merge(
    {
      Name = "${var.cluster_identifier}-instance-${count.index}"
    },
    var.tags
  )
}
