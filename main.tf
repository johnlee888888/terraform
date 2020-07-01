provider "aws" {
  version = "2.8"
  region = var.aws_region
}

resource "aws_vpc" "lizy_aws_vpc" {
  cidr_block = "10.92.0.0/16"
  tags = {
    Name = "lizy_aws_vpc"
  }
}