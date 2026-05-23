resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cachet-vpc"
  }
}

data "aws_availavility_zone" "available" {
    state = "available"
}

resource "aws_subnet" "public_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = data.aws_availavility_zones.names[0]

    tags = {
      Name = "cachet-public-1"
    }
}
