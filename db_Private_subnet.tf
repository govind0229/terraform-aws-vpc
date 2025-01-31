# Database Private subnet
resource "aws_subnet" "db_private_subnet" {
  count                   = var.create_vpc && length(var.db_private_subnets_cidr) > 0 ? length(var.db_private_subnets_cidr) : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.db_private_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-${var.environment}-Database-private-subnet-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_vpc.this]
}

# Private subnet route table
resource "aws_route_table" "db_private_subnet_route_table" {
  count  = var.create_vpc && length(var.db_private_subnets_cidr) > 0 ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags = {
    Name = "${var.vpc_name}-${var.environment}-Database-route-table-${var.availability_zones[count.index]}"
  }
}

# Private subnet route table association
resource "aws_route_table_association" "db_private_subnet_route_table_association" {
  count          = var.create_vpc && length(var.db_private_subnets_cidr) > 0 ? length(var.db_private_subnets_cidr) : 0
  subnet_id      = aws_subnet.db_private_subnet[count.index].id
  route_table_id = aws_route_table.db_private_subnet_route_table[0].id
}

# Private subnet EIP
# resource "aws_eip" "Database_public_subnet_eip" {
#   count  = var.create_vpc ? local.db_private_subnets_count : 0
#   domain = "vpc"
#   tags = {
#     Name        = "${var.vpc_name}-${var.environment}-Database-private-eip-${var.availability_zones[count.index]}"
#     Environment = var.environment
#     Teams       = var.teams
#     Terraform   = true
#   }
# }

# Public nat gateway 
# resource "aws_nat_gateway" "Database_public_subnet_nat_gateway" {
#   count         = var.create_vpc && length(var.db_private_subnets_cidr) > 0 ? 1 : 0
#   allocation_id = aws_eip.Database_public_subnet_eip[0].id
#   subnet_id     = aws_subnet.this[count.index].id
#   tags = {
#     Name        = "${var.vpc_name}-${var.environment}-Database-public-nat-gateway-${var.availability_zones[count.index]}"
#     Environment = var.environment
#     Teams       = var.teams
#     Terraform   = true
#   }

#   depends_on = [aws_subnet.this]
# }

# Private subnet route table route
# resource "aws_route" "db_private_subnet_route_table_route" {
#   count                  = var.create_vpc && length(var.db_private_subnets_cidr) > 0 ? 1 : 0
#   route_table_id         = aws_route_table.db_private_subnet_route_table[0].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.Database_public_subnet_nat_gateway[0].id

#   depends_on = [aws_nat_gateway.Database_public_subnet_nat_gateway]
# }
