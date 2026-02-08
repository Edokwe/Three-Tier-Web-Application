
# ---------------------------------------------------------------------------------------------------------------------
# Route Tables
# ---------------------------------------------------------------------------------------------------------------------

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.env}-public-rt"
    Environment = var.env
  }
}

# Private App Route Table
# If single_nat_gateway is true, we create one route table for all private subnets pointing to the single NAT.
# If single_nat_gateway is false, we create one route table per AZ/subnet pointing to the respective NAT.
resource "aws_route_table" "private_app" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_app_subnets)) : 1
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
    }
  }

  tags = {
    Name        = "${var.env}-private-app-rt-${count.index + 1}"
    Environment = var.env
  }
}

# Private Data Route Table (Isolated)
resource "aws_route_table" "private_data" {
  vpc_id = aws_vpc.this.id

  # No route to 0.0.0.0/0
  
  tags = {
    Name        = "${var.env}-private-data-rt"
    Environment = var.env
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Route Table Associations
# ---------------------------------------------------------------------------------------------------------------------

# Public Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private App Associations
resource "aws_route_table_association" "private_app" {
  count          = length(var.private_app_subnets)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private_app[0].id : aws_route_table.private_app[count.index].id
}

# Private Data Associations
resource "aws_route_table_association" "private_data" {
  count          = length(var.data_subnets)
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_data.id
}
