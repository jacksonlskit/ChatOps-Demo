resource "aws_vpc" "Chatdemo_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "Chatdemo_igw" {
  vpc_id = aws_vpc.Chatdemo_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_subnet" "Chatdemo_public_subnet" {
  vpc_id                  = aws_vpc.Chatdemo_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table" "Chatdemo_public_rt" {
  vpc_id = aws_vpc.Chatdemo_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route" "Chatdemo_public_route" {
  route_table_id         = aws_route_table.Chatdemo_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Chatdemo_igw.id
}

resource "aws_route_table_association" "Chatdemo_public_rt_assoc" {
  subnet_id      = aws_subnet.Chatdemo_public_subnet.id
  route_table_id = aws_route_table.Chatdemo_public_rt.id
}

