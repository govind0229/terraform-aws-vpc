# Terraform AWS VPC Module

This module creates a Virtual Private Cloud (VPC) on AWS with public and private subnets, NAT gateways, and other necessary resources.

## Features

- Create a VPC with customizable CIDR block
- Public and private subnets
- NAT gateways for private subnets
- Internet gateway
- Route tables and route table associations

## Usage

```hcl
module "vpc" {
    source = "govind0229/vpc"

    vpc_cidr = "10.0.0.0/16"

    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

    enable_nat_gateway = true
    single_nat_gateway = true

    tags = {
        Name = "my-vpc"
    }
}
```

## Inputs

| Name               | Description                           | Type   | Default | Required |
| ------------------ | ------------------------------------- | ------ | ------- | -------- |
| vpc_cidr           | The CIDR block for the VPC            | string | n/a     | yes      |
| public_subnets     | List of public subnet CIDR blocks     | list   | n/a     | yes      |
| private_subnets    | List of private subnet CIDR blocks    | list   | n/a     | yes      |
| enable_nat_gateway | Flag to enable/disable NAT gateways   | bool   | true    | no       |
| single_nat_gateway | Flag to create a single NAT gateway   | bool   | true    | no       |
| tags               | A map of tags to add to all resources | map    | {}      | no       |

## Outputs

| Name            | Description                    |
| --------------- | ------------------------------ |
| vpc_id          | The ID of the VPC              |
| public_subnets  | The IDs of the public subnets  |
| private_subnets | The IDs of the private subnets |
| nat_gateway_ids | The IDs of the NAT gateways    |

## License

This project is licensed under the MIT License.

## Authors

This module is maintained by [Govind Kumar](https://github.com/govind0229).

## Additional Features

- Control plane and database subnets
- Transit Gateway integration
- Enable/disable features based on user requirements

## Additional Inputs

| Name                   | Description                              | Type | Default | Required |
| ---------------------- | ---------------------------------------- | ---- | ------- | -------- |
| control_plane_subnets  | List of control plane subnet CIDR blocks | list | n/a     | no       |
| db_subnets             | List of database subnet CIDR blocks      | list | n/a     | no       |
| enable_transit_gateway | Flag to enable/disable Transit Gateway   | bool | false   | no       |

## Additional Outputs

| Name                      | Description                          |
| ------------------------- | ------------------------------------ |
| control_plane_subnets_ids | The IDs of the control plane subnets |
| db_subnets_ids            | The IDs of the database subnets      |
| transit_gateway_id        | The ID of the Transit Gateway        |
