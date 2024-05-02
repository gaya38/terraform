hcl
provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr
  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr
  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.igw_name
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = var.nat_name
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route_table" "public_route_tbl" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_tbl.id
}

resource "aws_vpc_peering_connection" "peer" {
  provider            = "aws.vpc2"
  vpc_id              = aws_vpc.vpc1.id
  peer_vpc_id         = aws_vpc.vpc2.id
  peer_region         = var.peer_region
  auto_accept         = true
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.public_route_tbl.id
  destination_cidr_block = aws_subnet.public_subnet.cidr_block
  gateway_id             = aws_vpc_peering_connection.peer.id
}
