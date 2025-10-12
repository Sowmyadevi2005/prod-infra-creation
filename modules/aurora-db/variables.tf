# Unique name for the Aurora cluster
variable "cluster_identifier" { 
  type        = string
  description = "Aurora cluster identifier"
}

# Database engine type (default: Aurora MySQL)
variable "engine" {
  type        = string
  default     = "aurora-mysql"
  description = "Aurora database engine type"
}

# Version of the Aurora database engine
variable "engine_version" {
  type        = string
  default     = "8.0.mysql_aurora.3.04.1"
  description = "Aurora database engine version"
}

# Master database username
variable "master_username" {
  type        = string
  description = "Master DB username"
}

# Master database password (sensitive)
variable "master_password" {
  type        = string
  description = "Master DB password"
  sensitive   = true
}

# Default database name created in the cluster
variable "database_name" {
  type        = string
  description = "Default database name"
}

# VPC where Aurora cluster will be deployed
variable "vpc_id" {
  type        = string
  description = "VPC ID where Aurora will be deployed"
}

# Subnet IDs for Aurora DB subnet group
variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for Aurora DB subnet group"
}

# Security group IDs attached to the Aurora cluster
variable "security_group_ids" {
  type        = list(string)
  description = "Security groups attached to Aurora cluster"
}

# Instance class used for Aurora instances
variable "instance_class" {
  type        = string
  default     = "db.r6g.large"
  description = "Instance class for Aurora instances"
}

# Number of Aurora instances to create
variable "instances" {
  type        = number
  default     = 2
  description = "Number of Aurora instances"
}

# Number of days to retain database backups
variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Backup retention period in days"
}

# Daily backup window time range
variable "preferred_backup_window" {
  type        = string
  default     = "02:00-03:00"
  description = "Daily time range for backups"
}

# Weekly maintenance window time range
variable "preferred_maintenance_window" {
  type        = string
  default     = "sun:05:00-sun:06:00"
  description = "Weekly time range for maintenance"
}

# Common tags applied to Aurora resources
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to Aurora resources"
}
