############################################# TERRAFORM #############################################
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    "Name"      = join("-", [lower(var.prefix), "vpc", lower(var.environment), format("%02d", var.number_of_sequence)])
    "CreatedAt" = timestamp()
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 10)
  availability_zone_id = data.aws_availability_zones.azs.zone_ids[1]

  tags = {
    "Name" = join("-", [lower(var.prefix), "public", "subnet", lower(var.environment), format("%02d", sum([var.number_of_sequence, 0]))])
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 11)
  availability_zone_id = data.aws_availability_zones.azs.zone_ids[2]

  tags = {
    "Name" = join("-", [lower(var.prefix), "public", "subnet", lower(var.environment), format("%02d", sum([var.number_of_sequence, 1]))])
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = join("-", [lower(var.prefix), "igw", lower(var.environment), format("%02d", var.number_of_sequence)])
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 20)
  availability_zone_id = data.aws_availability_zones.azs.zone_ids[1]

  tags = {
    "Name" = join("-", [lower(var.prefix), "private", "subnet", lower(var.environment), format("%02d", sum([var.number_of_sequence, 0]))])
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 21)
  availability_zone_id = data.aws_availability_zones.azs.zone_ids[2]

  tags = {
    "Name" = join("-", [lower(var.prefix), "private", "subnet", lower(var.environment), format("%02d", sum([var.number_of_sequence, 1]))])
  }
}

resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Name = join("-", [lower(var.prefix), "eip", lower(var.environment), format("%02d", var.number_of_sequence)])
  }
}

resource "aws_nat_gateway" "ngw" {
  connectivity_type = "public"
  allocation_id     = aws_eip.eip.id
  subnet_id         = aws_subnet.public_subnet_a.id

  tags = {
    Name = join("-", [lower(var.prefix), "ngw", lower(var.environment), format("%02d", var.number_of_sequence)])
  }

  depends_on = [
    aws_eip.eip,
    aws_internet_gateway.igw
  ]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = join("-", [lower(var.prefix), "public", "rt", lower(var.environment), format("%02d", var.number_of_sequence)])
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    "Name" = join("-", [lower(var.prefix), "private", "rt", lower(var.environment), format("%02d", var.number_of_sequence)])
  }
}

resource "aws_route_table_association" "public_route_table_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}
