locals {
  instance_name = var.instance_name
  region       = var.region
  instance_type = var.instance_type
  nvidia_ami = var.nvidia_ami
  nvidia_ov_ami = var.nvidia_ov_ami
  # vpc_cidr
}

terraform {
  required_version = ">= 1.2.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.30.0"
    }
  }

}

provider "aws" {
  profile = "default"
  region = local.region
}

# NVIDIA Omniverse GPU-Optimized for running Isaac-Sim Container
resource "aws_instance" "isaac_sim_oige" {
  ami             = "ami-0277b52859bac6f4b"
  instance_type   = local.instance_type
  key_name        = "isaac-sim-oige-key"
  user_data	    = file("isaac-sim-oige.sh")
  security_groups = [ "Docker" ]

  tags = {
    Name = "isaac-sim-oige"
  }

  depends_on = [  ] # should depend on the seucrity group
}

#---------------------------------------------------------------
# Images - AMI
#---------------------------------------------------------------
data "aws_ami" "example" {
  executable_users = ["self"]
  most_recent      = true
  name_regex       = "^myami-\\d{3}"
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["myami-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#---------------------------------------------------------------
# Network & Security
#---------------------------------------------------------------
resource "aws_security_group" "Docker" {
  tags = {
    type = "terraform-test-security-group"
  }
}

resource "aws_key_pair" "isaac-sim-oige-public-key" {
  key_name   = "isaac-sim-oige-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "isaac-sim-oige-private-key" {
  content = tls_private_key.rsa.private_key_pem
  filename = "isaac-sim-oige-private-key"
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name = local.instance_name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 3, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 3, k + length(local.azs))]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.cluster_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.cluster_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.cluster_name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  tags = local.tags
}