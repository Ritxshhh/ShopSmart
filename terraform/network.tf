# ============================================================
# Network — Auto-discover default VPC, subnets & security group
# No TF_VAR_SUBNET_IDS or TF_VAR_SG_ID secrets needed.
# ============================================================

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}
