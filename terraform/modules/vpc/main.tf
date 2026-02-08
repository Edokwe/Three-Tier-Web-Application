
# ---------------------------------------------------------------------------------------------------------------------
# VPC Creation
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.env}-${var.vpc_name}"
    Environment = var.env
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------------------------------------------------

# Public Subnets (Public Tier)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.env}-public-subnet-${count.index + 1}"
    Tier        = "Public"
    Environment = var.env
  }
}

# Private Subnets (App Tier)
resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_app_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name        = "${var.env}-private-app-subnet-${count.index + 1}"
    Tier        = "Private-App"
    Environment = var.env
  }
}

# Data Subnets (Database Tier)
resource "aws_subnet" "private_data" {
  count             = length(var.data_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.data_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name        = "${var.env}-private-data-subnet-${count.index + 1}"
    Tier        = "Private-Data"
    Environment = var.env
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.env}-igw"
    Environment = var.env
  }
}
