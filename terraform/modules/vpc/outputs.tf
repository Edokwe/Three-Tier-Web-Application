
output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_app_subnets" {
  description = "List of IDs of private app subnets"
  value       = aws_subnet.private_app[*].id
}

output "private_data_subnets" {
  description = "List of IDs of private data subnets"
  value       = aws_subnet.private_data[*].id
}

output "nat_gateway_ips" {
  description = "List of Elastic IPs associated with NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}
