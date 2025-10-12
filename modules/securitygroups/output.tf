output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
output "instance_sg_id" {
  value = aws_security_group.instance_sg.id
}
output "aurora_sg_id" {
  value = aws_security_group.aurora_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}