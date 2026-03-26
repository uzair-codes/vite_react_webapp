output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.alb.dns_name
}

output "bastion_public_ip" {
  description = "Bastion public IP (EIP)"
  value       = aws_eip.bastion_eip.public_ip
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "asg_name" {
  value = aws_autoscaling_group.web_asg.name
}
