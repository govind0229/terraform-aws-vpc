# Purpose: Create IAM roles and policies for VPC Flow Logs
resource "aws_iam_role" "flow_logs" {
  count = local.create_vpc && var.flow_logs_enabled ? 1 : 0

  name = "${var.vpc_name}-flow_logs_role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = local.create_vpc && var.flow_logs_enabled ? 1 : 0

  name = "${var.vpc_name}-flow_logs_policy-${var.environment}"
  role = aws_iam_role.flow_logs[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
