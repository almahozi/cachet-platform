output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public_1.id
}

output "security_group_id" {
  value = aws_security_group.cachet_sg.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "db_security_group_id" {
  value       = aws_security_group.db_sg.id
  description = "The ID of the RDS security group"
}