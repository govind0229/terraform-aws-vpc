output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this[0].id
}

output "public_subnet_ids" {
  description = "The IDs of the Public subnets"
  value       = aws_subnet.this[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the Private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "control_plane_subnets_ids" {
  description = "The IDs of the Control Plane Private subnets"
  value       = aws_subnet.control_plane_private_subnets[*].id
}

output "db_subnet_ids" {
  description = "The IDs of the Database Private subnets"
  value       = aws_subnet.db_private_subnet[*].id
}

output "db_cidr_block" {
  description = "CIDR block for the Database Private subnets"
  value       = aws_subnet.db_private_subnet[*].cidr_block
}

output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = var.transit_gateway_id
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs[*].arn
}
