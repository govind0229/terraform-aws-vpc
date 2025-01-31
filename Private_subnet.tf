# Private subnet
resource "aws_subnet" "private_subnets" {
  count                   = var.create_vpc && length(var.private_subnets_cidr) > 0 ? length(var.private_subnets_cidr) : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.private_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.vpc_name}-${var.environment}-private-subnet-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [aws_vpc.this]
}

#   Private subnet route table
resource "aws_route_table" "private_subnets_route_table" {
  count = local.create_nat_gateway ? length(var.private_subnets_cidr) : 0

  vpc_id = aws_vpc.this[0].id
  tags = {
    Name = "${var.vpc_name}-${var.environment}-private-subnet-route-table"
  }
}

resource "aws_route_table" "private_subnets_route_table_tgw_attachment" {
  count = local.create_tgw_attachment ? 1 : 0

  vpc_id = aws_vpc.this[0].id
  tags = {
    Name = "${var.vpc_name}-${var.environment}-private-subnet-route-table"
  }
}

#   Private subnet route table association
locals {
  worker_route_tables = local.create_tgw_attachment == true ? aws_route_table.private_subnets_route_table_tgw_attachment[*].id : aws_route_table.private_subnets_route_table[*].id
}


resource "aws_route_table_association" "private_subnets_route_table_association" {
  count          = var.create_vpc ? local.private_subnet_count : 0
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = element(local.worker_route_tables, count.index)
}

#  Private subnet EIP
resource "aws_eip" "worker_public_subnet_eip" {
  count = local.create_nat_gateway ? local.private_subnet_count : 0

  domain = "vpc"
  tags = {
    Name = "${var.vpc_name}-${var.environment}-private-subnet-eip-${var.availability_zones[count.index]}"
  }
}

# Public nat gateway   
resource "aws_nat_gateway" "worker_public_subnet_nat_gateway" {
  count = local.create_nat_gateway ? local.private_subnet_count : 0

  allocation_id = aws_eip.worker_public_subnet_eip[count.index].id
  subnet_id     = aws_subnet.this[count.index].id
  tags = {
    Name = "${var.vpc_name}-${var.environment}-private-subnet-public-nat-gateway-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_subnet.this]
}

# Private nat gateway
resource "aws_nat_gateway" "private_subnets_nat_gateway" {
  count = local.create_nat_gateway ? local.private_subnet_count : 0

  connectivity_type = "private"
  subnet_id         = aws_subnet.private_subnets[count.index].id

  tags = {
    Name = "${var.vpc_name}-${var.environment}-private-subnet-private-nat-gateway-${var.availability_zones[count.index]}"
  }
}

# Private subnet route table route
resource "aws_route" "private_subnets_route_table_route" {
  count = local.create_nat_gateway ? local.private_subnet_count : 0

  route_table_id         = element(local.worker_route_tables, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.worker_public_subnet_nat_gateway[count.index].id

  lifecycle {
    ignore_changes = [route_table_id, destination_cidr_block]
  }
}

#   Private subnet route table route
resource "aws_route" "private_subnets_route_table_route_private" {
  count = local.create_nat_gateway ? local.private_subnet_count : 0

  route_table_id         = element(local.worker_route_tables, count.index)
  destination_cidr_block = "10.0.0.0/8"
  nat_gateway_id         = aws_nat_gateway.private_subnets_nat_gateway[count.index].id

  lifecycle {
    ignore_changes = [route_table_id, destination_cidr_block]
  }
}

#  Private subnet route table route for tgw attachment
resource "aws_route" "private_subnets_route_table_route_tgw" {
  count = local.create_tgw_attachment ? 1 : 0

  route_table_id         = element(local.worker_route_tables, count.index)
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id

  lifecycle {
    ignore_changes = [route_table_id, destination_cidr_block]
  }
}
