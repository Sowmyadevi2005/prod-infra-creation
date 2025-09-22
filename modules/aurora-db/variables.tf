variable "cluster_identifier" {
  type        = string
  description = "Aurora cluster identifier"
}

variable "engine" {
  type        = string
  default     = "aurora-mysql"
  description = "Aurora database engine type"
}

variable "engine_version" {
  type        = string
  default     = "8.0.mysql_aurora.3.04.1"
  description = "Aurora database engine version"
}

variable "master_username" {
  type        = string
  description = "Master DB username"
}

variable "master_password" {
  type        = string
  description = "Master DB password"
  sensitive   = true
}

variable "database_name" {
  type        = string
  description = "Default database name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Aurora will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for Aurora DB subnet group"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups attached to Aurora cluster"
}

variable "instance_class" {
  type        = string
  default     = "db.r6g.large"
  description = "Instance class for Aurora instances"
}

variable "instances" {
  type        = number
  default     = 2
  description = "Number of Aurora instances"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Backup retention period in days"
}

variable "preferred_backup_window" {
  type        = string
  default     = "02:00-03:00"
  description = "Daily time range for backups"
}

variable "preferred_maintenance_window" {
  type        = string
  default     = "sun:05:00-sun:06:00"
  description = "Weekly time range for maintenance"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to Aurora resources"
}
