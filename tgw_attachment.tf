#  Transit attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "central_egress_transit_gateway_vpc_attachment" {
  count              = local.create_tgw_attachment == true ? 1 : 0
  subnet_ids         = aws_subnet.private_subnets[*].id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.this[0].id
  tags = {
    Name = "${var.vpc_name}-${var.environment}-transit-attachment"
  }
}

