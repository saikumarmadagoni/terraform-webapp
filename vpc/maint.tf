provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "100.65.0.0/16"
}


resource "aws_subnet" "public-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-1"
  }
}


resource "aws_subnet" "public-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "public-2"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "100.65.1.0/24"

  tags = {
    Name = "private-1"

  }
}


resource "aws_subnet" "private-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "100.65.2.0/24"

  tags = {
    Name = "private-2"

  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "100.65.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "public"
  }
}


resource "aws_route_table_association" "publicassosciation1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "publicassosciation2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat1" {
  
  domain   = "vpc"
}


resource "aws_eip" "nat2" {
  
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public-1.id
}

resource "aws_nat_gateway" "ngw2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public-2.id
}


resource "aws_route_table" "privatesub1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw1.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "100.65.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "privateroutetable1"
  }
}


resource "aws_route_table" "privatesub2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw2.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "100.65.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "privateroutetable2"
  }
}


resource "aws_route_table_association" "privateassosciation1" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.privatesub1.id
}

resource "aws_route_table_association" "privateassosciation2" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.privatesub2.id
}