provider "aws" {
  region = "eu-central-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Subnets
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Route Table Associations
resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}

# Security Group for Ubuntu - deny all
resource "aws_security_group" "ubuntu_sg" {
  name        = "ubuntu-deny-all"
  description = "No traffic allowed"
  vpc_id      = aws_vpc.main.id

  ingress {} # No inbound rules
  egress {}  # No outbound rules
}

# Security Group for Amazon Linux - deny all
resource "aws_security_group" "amazon_sg" {
  name        = "amazon-deny-all"
  description = "No traffic allowed"
  vpc_id      = aws_vpc.main.id

  ingress {}
  egress {}
}

# Ubuntu EC2
resource "aws_instance" "ubuntu" {
  ami                         = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 LTS in eu-central-1
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet1.id
  associate_public_ip_address = true
  key_name                    = "thomas-key"
  vpc_security_group_ids      = [aws_security_group.ubuntu_sg.id]
  tags = {
    Name = "UbuntuInstance"
  }
}

# Amazon Linux EC2
resource "aws_instance" "amazon_linux" {
  ami                         = "ami-0b2f6494ff0b07a0e" # Amazon Linux 2023 in eu-central-1
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet2.id
  associate_public_ip_address = true
  key_name                    = "thomas-key"
  vpc_security_group_ids      = [aws_security_group.amazon_sg.id]
  tags = {
    Name = "AmazonLinuxInstance"
  }
}