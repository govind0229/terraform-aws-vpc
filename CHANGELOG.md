# Changelog

## [1.0.0] - 2025-01-31

### Added

- Initial release of the VPC module
- Support for creating VPC with customizable CIDR block
- Subnet creation with public, private, and isolated options
- Internet Gateway and NAT Gateway support
- Route Table and Route configurations
- Support for VPC Flow Logs

### Changed

- N/A

### Removed

- N/A

## [1.0.1] - 2025-01-31

### Added

- Add README.md

### Changed

- N/A

### Removed

- readme.md file removed

## [1.0.2] - 2025-01-31

### Added

- secondary VPC CIDR for EKS support

### Changed

- Change `public_subnets` variable to `public_subnets_cidr`
- Update variables description
- Update db subnet name

### Removed

- N/A
