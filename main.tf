locals {
  create_vpc = var.create_vpc && var.vpc_cidr_block != null && var.vpc_name != null && var.environment != null && var.teams != null
}

# VPC
resource "aws_vpc" "this" {
  count                = local.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.vpc_name}-${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count      = local.create_vpc && length(var.secondary_cidr_blocks) > 0 ? 1 : 0
  vpc_id     = aws_vpc.this[0].id
  cidr_block = var.secondary_cidr_blocks

  depends_on = [aws_vpc.this]

  lifecycle {
    create_before_destroy = true
  }
}

# Public/Private subnet
resource "aws_subnet" "this" {
  count                   = local.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = length(var.public_subnets) > 0 ? true : false

  tags = {
    Name                     = "${var.vpc_name}-${var.environment}-public-subnet-${count.index}-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb" = "1"
  }

  depends_on = [aws_vpc.this]
}

# Default Route Table
resource "aws_default_route_table" "this" {
  count                  = local.create_vpc ? 1 : 0
  default_route_table_id = aws_vpc.this[0].default_route_table_id
  tags = {
    Name = "${var.vpc_name}-${var.environment}-public-route-table"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  tags = {
    Name = "${var.vpc_name}-public-igw"
  }
}

# Route
resource "aws_route" "this" {
  count                  = local.create_vpc && length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_vpc.this[0].default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

# Subnet Association
resource "aws_route_table_association" "this" {
  count          = local.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_default_route_table.this[0].id
}

# VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = local.create_vpc && var.flow_logs_enabled ? 1 : 0
  name              = "flow-logs-${aws_vpc.this[count.index].id}-${var.environment}"
  retention_in_days = var.flow_logs_retention_in_days
}

resource "aws_flow_log" "this" {
  count                = local.create_vpc && var.flow_logs_enabled ? 1 : 0
  iam_role_arn         = aws_iam_role.flow_logs[count.index].arn
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[count.index].arn
  log_destination_type = var.flow_logs_log_destination_type
  traffic_type         = var.flow_logs_traffic_type
  vpc_id               = aws_vpc.this[0].id
}
