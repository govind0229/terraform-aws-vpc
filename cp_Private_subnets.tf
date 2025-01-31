# Control Plan Create private subnets
resource "aws_subnet" "control_plane_private_subnets" {
  count                   = length(var.control_plane_private_subnets_cidr)
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.control_plane_private_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  depends_on = [
    aws_vpc.this,
    aws_vpc_ipv4_cidr_block_association.this
  ]

  tags = {
    Name = "${var.vpc_name}-${var.environment}-control-plane-subnet-${var.availability_zones[count.index]}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# route table for control plan private subnets
resource "aws_route_table" "control_plane_private_subnets_route_table" {
  count = local.create_nat_gateway == true ? 1 : 0

  vpc_id = aws_vpc.this[0].id
  tags = {
    Name = "${var.vpc_name}-${var.environment}-control-plane-route-table-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "control_plane_private_subnets_route_table_tgw_attachment" {
  count = local.create_tgw_attachment == true ? 1 : 0

  vpc_id = aws_vpc.this[0].id
  tags = {
    Name = "${var.vpc_name}-${var.environment}-control-plane-route-table-${var.availability_zones[count.index]}"
  }
}

# route table association for control plan private subnets
locals {
  route_table_id = local.create_nat_gateway == true ? aws_route_table.control_plane_private_subnets_route_table[0].id : aws_route_table.control_plane_private_subnets_route_table_tgw_attachment[0].id
}


resource "aws_route_table_association" "control_plane_private_subnets_route_table_association" {
  count          = length(var.control_plane_private_subnets_cidr) > 0 ? length(var.control_plane_private_subnets_cidr) : 0
  subnet_id      = aws_subnet.control_plane_private_subnets[count.index].id
  route_table_id = local.route_table_id
}


# EIP for control plan private subnets
resource "aws_eip" "control_plane_private_subnets_eip" {
  count = local.create_tgw_attachment == false || local.create_nat_gateway ? 1 : 0

  domain = "vpc"
  tags = {
    Name = "${var.vpc_name}-${var.environment}-control-plane-subnet-eip-${var.availability_zones[count.index]}"
  }
}

# NAT gateway for control plan Public subnets
resource "aws_nat_gateway" "control_plan_public_subnets_nat_gateway" {
  count = local.create_tgw_attachment == false || local.create_nat_gateway ? 1 : 0

  allocation_id = aws_eip.control_plane_private_subnets_eip[0].id
  subnet_id     = aws_subnet.this[count.index].id
  tags = {
    Name = "${var.vpc_name}-${var.environment}-control-plane-subnet-nat-gateway-${var.availability_zones[count.index]}"
  }
}

# route table for control plan private subnets
resource "aws_route" "control_plane_private_subnets_route" {
  count = local.create_tgw_attachment == false || local.create_nat_gateway ? 1 : 0

  route_table_id         = local.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.control_plan_public_subnets_nat_gateway[0].id

  lifecycle {
    ignore_changes = [route_table_id, destination_cidr_block]
  }
}


# route table for tgw attachment
resource "aws_route" "control_plane_private_subnets_tgw_attachment_route" {
  count = local.create_tgw_attachment == true ? 1 : 0

  route_table_id         = local.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id

  lifecycle {
    ignore_changes = [route_table_id, destination_cidr_block]
  }

}
