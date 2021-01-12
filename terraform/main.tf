provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "snapshots-vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-northeast-1a", "ap-northeast-1c"]
  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "Snapshots"
  }
}

module "nomad-starter" {
  source = "./terraform-aws-nomad-starter"

  allowed_inbound_cidrs = [var.allowed_inbound_cidrs]
  vpc_id                = module.vpc.vpc_id
  consul_version        = "1.9.0"
  nomad_version         = "1.0.1"
  owner                 = var.owner
  name_prefix           = var.prefix
  key_name              = var.key_name
  nomad_servers         = var.servers
  nomad_clients         = var.clients
  instance_type         = var.instance_type
  enable_connect        = true # make sure "connect" is enabled
  public_ip             = true
}

# Ingress for frontend
data "aws_security_groups" "sg_id" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  filter {
    name   = "group-name"
    values = ["${var.prefix}-*"]
  }

  depends_on = [
    module.nomad-starter
  ]
}

resource "aws_security_group_rule" "frontend" {
  security_group_id = data.aws_security_groups.sg_id.ids[0]
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_inbound_cidrs]
}

# Get public IPs

data "aws_instances" "servers" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-*-server"]
  }

  depends_on = [
    module.nomad-starter
  ]
}

data "aws_instances" "clients" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-*-client"]
  }

  depends_on = [
    module.nomad-starter
  ]
}

