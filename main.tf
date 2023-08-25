
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


==================================================== Create Security Group ==================================================================
resource "aws_security_group" "demo-sg" {
  name        = "demovpc-sg"
  description = "Allow HTTP and SSH traffic via Terraform"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

======================================================================= Launch an EC2 Instance in the public Subnet ===================================================
resource "aws_instance" "web_instance" {
  ami                    = "ami-0ed752ea0f62749af"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.pubsub1.id
  key_name               = "EC2Tutorial"
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  user_data              = <<EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd
  systemctl start httpd.service
  systemctl enable httpd.service
  cd /var/www/html/
  echo "<html><body><h1>Welcome to AC-IT Training Solutions</h1></body></html>" > index.html 
  EOF
  tags = {
    name = "Web-Server01"
  }
}

======================================================================= Launch an EC2 Instance in the private Subnet ===================================================

resource "aws_instance" "DB_instance" {
  ami                    = "ami-0ed752ea0f62749af"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.prisub1.id
  key_name               = "EC2Tutorial"
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  tags = {
    name = "DB-Server01"
  }
}


