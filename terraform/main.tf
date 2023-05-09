locals {
  instance_name = var.instance_name
  region       = var.region
  instance_type = var.instance_type
  nvidia_ami = var.nvidia_ami
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
  # profile = "default"
  region = local.region
}

#---------------------------------------------------------------
# Create the Instance
# NVIDIA Omniverse GPU-Optimized for running Isaac-Sim Container
resource "aws_instance" "isaac_sim_oige" {
  # ami             = local.nvidia_ami
  ami             = data.aws_ami_ids.nvidia_omniverse_ami.id
  instance_type   = local.instance_type
  key_name        = "isaac-sim-oige-key"
  user_data	      = file("isaac-sim-oige.sh")
  # user_data	      = file("isaac-sim-oige-v2.sh")
  security_groups = [ aws_security_group.sg_isaac_sim_oige.id ]

  # We Gonna pick the first availability zone that has the Instance Type we want
  availability_zone = keys({ for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
  az => details.instance_types if length(details.instance_types) != 0 })[0]

  subnet_id       = aws_subnet.subnet.id

  # Env = "isaac-sim"
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 200
  }

  tags = {
    Name = local.instance_name
    Env = var.env
  }

  depends_on = [
    aws_security_group.sg_isaac_sim_oige, 
    aws_key_pair.isaac-sim-oige-public-key
  ]
}

#---------------------------------------------------------------
# Images - AMI
#---------------------------------------------------------------
# Looking for NVIDIA Omniverse GPU-Optimized AMI
data "aws_ami_ids" "nvidia_omniverse_ami" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["OV AMI 1.3.6*"]
  }
}
#---------------------------------------------------------------
# List of Availability Zones in a Specific Region
#---------------------------------------------------------------
# return a list of all Availability Zones in a Specific Region
data "aws_availability_zones" "my_azones" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

#---------------------------------------------------------------
# Instance Availability
#---------------------------------------------------------------
# Return Boolean if the instance type is available on the zone
data "aws_ec2_instance_type_offerings" "my_ins_type" {
  for_each=toset(data.aws_availability_zones.my_azones.names)
    filter {
      name   = "instance-type"
      values = [local.instance_type]
    }
    filter {
      name   = "location"
      values = [each.key]
    }

    location_type = "availability-zone"
}
#---------------------------------------------------------------
# Network & Security
#---------------------------------------------------------------
# Security Group
#---------------------------------------------------------------
resource "aws_security_group" "sg_isaac_sim_oige" {
  name        = "sg_isaac_sim_oige"
  description = "Allow all traffic in and out so we can talk to Omniverse Services"
  vpc_id      = aws_vpc.vpc.id
# protocol of -1 is equivalent to all
  ingress {
    description      = "Allows all Traffic Ingress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allows all Traffic Egress"    
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_isaac_sim_oige"
    Env  = var.env
  }
  depends_on = [ aws_vpc.vpc ]
}
#---------------------------------------------------------------
# Create a Key Pair
#---------------------------------------------------------------
resource "aws_key_pair" "isaac-sim-oige-public-key" {
  key_name   = "isaac-sim-oige-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "isaac-sim-oige-private-key" {
  content = tls_private_key.rsa.private_key_openssh
  filename = "isaac-sim-oige-key.pem"
}
#---------------------------------------------------------------
# VPC
#---------------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.env}_vpc"
    Env  = var.env
  }

}
#---------------------------------------------------------------
# Subnet
#---------------------------------------------------------------
resource "aws_subnet" "subnet" {
  # We Gonna pick the first availability zone that has the Instance Type we want
  availability_zone = keys({ for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
  az => details.instance_types if length(details.instance_types) != 0 })[0]

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet

  map_public_ip_on_launch = "true"
  tags = {
      Name = "${var.env}_subnet"
      Env  = var.env
    }
  depends_on = [ aws_vpc.vpc ]
}
#---------------------------------------------------------------
# Internet Gateway
#---------------------------------------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
      Name = "${var.env}_gw"
      Env  = var.env
    }
  depends_on = [ aws_vpc.vpc ]
}
#---------------------------------------------------------------
# Route Table
#---------------------------------------------------------------
resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "default route table"
    env  = var.env
  }
  depends_on = [ aws_vpc.vpc ]
}
#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

#---------------------------------------------------------------
# Output
#---------------------------------------------------------------
output "ami_id" {
  value = data.aws_ami_ids.nvidia_omniverse_ami.ids
}

# Filtered Output: As the output is list now, get the first item from list (just for learning)
output "output_az" {
  value = keys({ for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
  az => details.instance_types if length(details.instance_types) != 0 })[0]
}