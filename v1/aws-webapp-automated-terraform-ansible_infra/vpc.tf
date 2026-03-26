resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = { Name = "webapp-vpc" }
}

# Public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "public-${count.index + 1}" }
}

# Private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = local.azs[count.index]
  tags = { Name = "private-${count.index + 1}" }
}

# Internet Gateway + Route Table
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "webapp-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "public-rt" }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateways
resource "aws_eip" "nat" {
  count = length(local.azs)
  domain   = "vpc"
  tags  = { Name = "nat-eip-${count.index + 1}" }
}

resource "aws_nat_gateway" "nat" {
  count         = length(local.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = { Name = "nat-gw-${count.index + 1}" }
  depends_on    = [aws_internet_gateway.igw]
}

# Private route tables
resource "aws_route_table" "private" {
  count  = length(local.azs)
  vpc_id = aws_vpc.main.id
  tags   = { Name = "private-rt-${count.index + 1}" }
}

resource "aws_route" "private_nat" {
  count                  = length(local.azs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
