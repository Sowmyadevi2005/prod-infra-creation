output "cluster_id" {
  value = aws_rds_cluster.aurora.id
}

output "cluster_endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.aurora.reader_endpoint
}

output "instance_endpoints" {
  value = [for i in aws_rds_cluster_instance.aurora_instances : i.endpoint]
}
