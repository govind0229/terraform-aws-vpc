locals {
  create_nat_gateway       = var.transit_gateway_id != "" ? false : true
  create_tgw_attachment    = var.transit_gateway_id != "" ? true : false
  private_subnet_count     = length(var.private_subnets_cidr)
  cp_subnet_count          = length(var.control_plane_private_subnets_cidr)
  db_private_subnets_count = length(var.db_private_subnets_cidr)
}

