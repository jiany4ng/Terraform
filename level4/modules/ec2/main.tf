resource "aws_security_group" "ubuntu_sg" {
  name        = "ubuntu-deny-all"
  description = "No traffic allowed"
  vpc_id      = aws_vpc.main.id

  ingress {}
  egress {}
}

resource "aws_security_group" "amazon_sg" {
  name        = "amazon-deny-all"
  description = "No traffic allowed"
  vpc_id      = aws_vpc.main.id

  ingress {}
  egress {}
}

resource "aws_instance" "ubuntu" {
  ami                         = "ami-0fc5d935ebf8bc3bc"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet1.id
  associate_public_ip_address = true
  key_name                    = "thomas-key"
  vpc_security_group_ids      = [aws_security_group.ubuntu_sg.id]
  tags = {
    Name = "UbuntuInstance"
  }
}

resource "aws_instance" "amazon_linux" {
  ami                         = "ami-0b2f6494ff0b07a0e"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet2.id
  associate_public_ip_address = true
  key_name                    = "thomas-key"
  vpc_security_group_ids      = [aws_security_group.amazon_sg.id]
  tags = {
    Name = "AmazonLinuxInstance"
  }
}