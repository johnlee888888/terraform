provider "aws" {
  version = "2.33.0"
  region = var.aws_region
}

resource "aws_vpc" "lizy_aws_vpc" {
  cidr_block = "10.92.0.0/16"
  tags = {
    Name = "lizy_aws_vpc"
  }
}

resource "aws_subnet" "lizy_outside_subnet" {
  cidr_block = "10.92.1.0/24"
  vpc_id = aws_vpc.lizy_aws_vpc.id
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "lizy_outside_subnet"
  }
}

resource "aws_internet_gateway" "lizy_internet_gw" {
  vpc_id = aws_vpc.lizy_aws_vpc.id
  tags = {
    Name = "lizy_igw"
  }
}

resource "aws_route_table" "lizy_aws_route_table" {
  vpc_id = aws_vpc.lizy_aws_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lizy_internet_gw.id
  }
  tags = {
    Name = "lizy_aws_route_table"
  }
}

resource "aws_route_table_association" "lizy_aws_route_table_association" {
  route_table_id = aws_route_table.lizy_aws_route_table.id
  subnet_id = aws_subnet.lizy_outside_subnet
}

resource "aws_dynamodb_table" "lizy_dynamic_table" {
  hash_key = "username"
  range_key = "phone"
  name = "staff"
  read_capacity = var.db_read_capacity
  write_capacity = var.db_write_capacity
  attribute {
    name = "username"
    type = "S"
  }
  attribute {
    name = "phone"
    type = "S"
  }
  tags = {
    Name = "staff"
  }
}

resource "aws_security_group" "lizy_aws_allow_ssh_web" {
  name = "allow_ssh_web80"
  description = "Allow ssh and web inbound traffic"
  vpc_id = aws_vpc.lizy_aws_vpc.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "lizy_aws_allow_ssh_web"
  }
}

resource "aws_instance" "amazon_linux_2" {
  ami = "ami-0a1c2ec61571737db"
  instance_type = "t2.micro"
  key_name = "lizy_aws"
  subnet_id = aws_subnet.lizy_outside_subnet
  iam_instance_profile = "WebService"
  security_groups = [aws_security_group.lizy_aws_allow_ssh_web.id]
  tags = {
    Name = "lizy_ec2"
  }
  user_data = file("user_data.sh")
}