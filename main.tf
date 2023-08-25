
#vpc resource
resource "aws_vpc" "vpc" {
  cidr_block = var.vpccidr

  # cidr block iteration found in the terraform.tfvars file
  tags = {
    Name = "demo-vpc"
  }
}

#Elastic IP for NAT Gateway resource
resource "aws_eip" "nat" {
  vpc = true
  tags = {
  Name = "demo-vpc" }
}

#NAT Gateway object and attachment of the Elastic IP Address from above
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pubsub1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "acit-ngw"
  }
}
#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "acit-igw"
  }
}

#Public Subnet 1

resource "aws_subnet" "pubsub1" {

  cidr_block = var.pubsub1cidr

  # public subnet 1 cidr block iteration found in the terraform.tfvars file
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  #0 indicates the first AZ
  tags = {
    Name = "Public-A"
  }
}

#Public Subnet 2
resource "aws_subnet" "pubsub2" {
  cidr_block = var.pubsub2cidr
  # public subnet 2 cidr block iteration found in the terraform.tfvars file
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  #1 indicates the second AZ
  tags = {
    Name = "Public-B"

  }

}

#Public Subnet 3
resource "aws_subnet" "pubsub3" {
  cidr_block = var.pubsub3cidr
  # public subnet 3 cidr block iteration found in the terraform.tfvars file
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[2]
  #2 indicates the 3rd AZ
  tags = {
    Name = "public-C"

  }
}

#Private Subnet 1
resource "aws_subnet" "prisub1" {
  cidr_block = var.prisub1cidr
  # private subnet 1 cidr block iteration found in the terraform.tfvars file
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {

    Name = "Private-A"

  }
}

#Private Subnet 2
resource "aws_subnet" "prisub2" {
  cidr_block = var.prisub2cidr
  # private subnet 2 cidr block iteration found in the terraform.tfvars file
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "Private-B"
  }

}

#Private Subnet 3
resource "aws_subnet" "prisub3" {
  cidr_block = var.prisub3cidr
  # private subnet 3 cidr block iteration found in the terraform.tfvars file
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "Private-C"

  }

}

#Public Route Table
resource "aws_route_table" "routetablepublic" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {
    Name = "public-rt"

  }

}

#Associate Public Route Table to Public Subnets
resource "aws_route_table_association" "pubrtas1" {
  subnet_id      = aws_subnet.pubsub1.id
  route_table_id = aws_route_table.routetablepublic.id

}

resource "aws_route_table_association" "pubrtas2" {
  subnet_id      = aws_subnet.pubsub2.id
  route_table_id = aws_route_table.routetablepublic.id

}


resource "aws_route_table_association" "pubrtas3" {
  subnet_id      = aws_subnet.pubsub3.id
  route_table_id = aws_route_table.routetablepublic.id
}

#Private Route Table
resource "aws_route_table" "routetableprivate" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id

  }

  tags = {

    Name = "private-rt"

  }

}

#Associate Private Route Table to Private Subnets
resource "aws_route_table_association" "prirtas1" {
  subnet_id      = aws_subnet.prisub1.id
  route_table_id = aws_route_table.routetableprivate.id

}

resource "aws_route_table_association" "prirtas2" {
  subnet_id      = aws_subnet.prisub2.id
  route_table_id = aws_route_table.routetableprivate.id

}

resource "aws_route_table_association" "prirtas3" {
  subnet_id      = aws_subnet.prisub3.id
  route_table_id = aws_route_table.routetableprivate.id

}
