# Network: VPC, Subnets, Route Table, Default SG of VPC

# ---------------------------------------------------------------------------------------------------------------------
# PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}


# ---------------------------------------------------------------------------------------------------------------------
# data
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
 
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

#---------------------------------------------------------------------------------------------------------------------
#public  sub nets
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "public_subnets" {
  count  = 4
  vpc_id = aws_vpc.vpc.id

  cidr_block              = element(var.public_subnets, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${var.prefix}-public-subnet-${count.index}"
  }
}
#---------------------------------------------------------------------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

#---------------------------------------------------------------------------------------------------------------------
# Route Table
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix}-public_rt"
  }
}

resource "aws_route_table_association" "public_subnet0_association" {
  subnet_id      = aws_subnet.public_subnets.0.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnets.1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnets.2.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_subnet3_association" {
  subnet_id      = aws_subnet.public_subnets.3.id
  route_table_id = aws_route_table.public_rt.id
}

#---------------------------------------------------------------------------------------------------------------------
# Default security group of vpc
# ---------------------------------------------------------------------------------------------------------------------
# data "aws_security_group" "default-sg" {
#   vpc_id = aws_vpc.vpc.id

#   filter {
#     name   = "group-name"
#     values = ["default"]
#   }
# }
# resource "aws_default_security_group" "default" {
#   vpc_id = aws_vpc.vpc.id

#   ingress {
#     protocol  = -1
#     self      = true
#     from_port = 0
#     to_port   = 0
#     security_groups  = [
#                   aws_security_group.ec2_sg.id
#                 ]
   
#   }
#   # egress {
#   #   from_port   = 0
#   #   to_port     = 0
#   #   protocol    = "-1"
#   #   cidr_blocks = ["0.0.0.0/0"]
#   # }
#   tags = {
#     Name = "${var.prefix}-default-vpc-sg"
#   }
# }