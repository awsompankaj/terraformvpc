resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}


resource "aws_subnet" "private01" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private01"
  }
}
resource "aws_subnet" "private02" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private02"
  }
}
resource "aws_subnet" "private03" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "private03"
  }
}



resource "aws_subnet" "public01" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.101.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public01"
  }
}
resource "aws_subnet" "public02" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.102.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public02"
  }
}
resource "aws_subnet" "public03" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.103.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "public03"
  }
}

resource "aws_route_table" "publicroutes" {
  vpc_id = aws_vpc.myvpc.id

  route = []

  tags = {
    Name = "publicroute"
  }
}

resource "aws_route_table_association" "public-01" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.publicroutes.id
}

resource "aws_route_table_association" "public-02" {
  subnet_id      = aws_subnet.public02.id
  route_table_id = aws_route_table.publicroutes.id
}
resource "aws_route_table_association" "public-03" {
  subnet_id      = aws_subnet.public03.id
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
  subnet_id      = aws_subnet.private01.id
  route_table_id = aws_route_table.privateroutes.id
}

resource "aws_route_table_association" "private-02" {
  subnet_id      = aws_subnet.private02.id
  route_table_id = aws_route_table.privateroutes.id
}
resource "aws_route_table_association" "private-03" {
  subnet_id      = aws_subnet.private03.id
  route_table_id = aws_route_table.privateroutes.id
}


resource "aws_route" "to-internetgateway" {
  route_table_id              = aws_route_table.publicroutes.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id     = aws_internet_gateway.mygateway.id
}

resource "aws_route" "to-natgateway" {
  route_table_id              = aws_route_table.privateroutes.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id     = aws_nat_gateway.mynatgateway.id
}

resource "aws_nat_gateway" "mynatgateway" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public01.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.mygateway]
}

resource "aws_eip" "lb" {
  vpc      = true
}





