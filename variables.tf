variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = ""
}

variable "secondary_cidr_blocks" {
  description = "Secondary CIDR blocks for the VPC"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = ""
}

variable "public_subnets" {
  description = "Availability zones for the VPC"
  type        = list(string)
  default     = []
}

variable "teams" {
  description = "Teams"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "Availability zones for the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for the Worker Private subnets"
  type        = list(string)
  default     = []
}

variable "control_plane_private_subnets_cidr" {
  description = "CIDR blocks for the Control Plane subnets"
  type        = list(string)
  default     = []
}

variable "db_private_subnets_cidr" {
  description = "CIDR blocks for the Database Private subnets"
  type        = list(string)
  default     = []
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
  default     = ""
}

variable "enable_nat_gateway" {
  description = "Controls if NAT Gateway should be created"
  type        = bool
  default     = false
}

# Flow Logs variables
variable "flow_logs_enabled" {
  description = "Controls if VPC Flow Logs should be created"
  type        = bool
  default     = false
}

variable "flow_logs_log_destination_type" {
  description = "The type of the log destination"
  type        = string
  default     = "cloud-watch-logs"
}

variable "flow_logs_traffic_type" {
  description = "The log format"
  type        = string
  default     = "ALL"
}

variable "flow_logs_retention_in_days" {
  description = "The number of days to retain the flow logs"
  type        = number
  default     = 14
}
