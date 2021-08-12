locals {
  count_pri_subnet = 3
  count_pub_subnet = 3
  private_cidr     = [for i in range(1, 100, 1) : cidrsubnet("10.0.0.0/16", 8, i)]
  public_cidr      = [for i in range(101, 200, 1) : cidrsubnet("10.0.0.0/16", 8, i)]
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}


resource "aws_subnet" "private" {
  count                   = local.count_pri_subnet
  vpc_id                  = aws_vpc.myvpc.id
  map_public_ip_on_launch = false
  cidr_block              = local.private_cidr[count.index]
  availability_zone       = data.aws_availability_zones.zones.names[count.index]

  tags = {
    Name = "private${count.index}"
  }
}

resource "aws_subnet" "public" {
  count                   = local.count_pub_subnet
  vpc_id                  = aws_vpc.myvpc.id
  map_public_ip_on_launch = false
  cidr_block              = local.public_cidr[count.index]
  availability_zone       = data.aws_availability_zones.zones.names[count.index]

  tags = {
    Name = "public${count.index}"
  }
}

resource "aws_route_table" "publicroutes" {
  vpc_id = aws_vpc.myvpc.id

  route = []

  tags = {
    Name = "publicroute"
  }
}

resource "aws_route_table_association" "public" {
  count          = local.count_pub_subnet
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.publicroutes.id
}


resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "mygateway"
  }
}


resource "aws_route_table" "privateroutes" {
  vpc_id = aws_vpc.myvpc.id

  route = []

  tags = {
    Name = "privateroute"
  }
}


resource "aws_route_table_association" "private-01" {
  count          = local.count_pri_subnet
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.privateroutes.id
}


resource "aws_route" "to-internetgateway" {
  route_table_id         = aws_route_table.publicroutes.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mygateway.id
}

resource "aws_route" "to-natgateway" {
  route_table_id         = aws_route_table.privateroutes.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.mynatgateway.id
}

resource "aws_nat_gateway" "mynatgateway" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.mygateway]
}

resource "aws_eip" "lb" {
  vpc = true
}





