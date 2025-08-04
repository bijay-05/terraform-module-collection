resource "aws_vpc" "testvpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
      environment = "test"
    }
}

resource "aws_subnet" "testsubnet" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = var.subnet_cidr
    availability_zone = var.availability_zone
    map_public_ip_on_launch = false

    tags = {
        environment = "test"
    }
}

resource "aws_internet_gateway" "testigw" {
    vpc_id = aws_vpc.testvpc.id

    tags = {
        environment = "test"
    }
}

resource "aws_route_table" "testroutetable" {
    vpc_id = aws_vpc.testvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.testigw.id
    }

    tags = {
        environment = "test"
    }
}

resource "aws_route_table_association" "testroutetableassociation" {
    subnet_id = aws_subnet.testsubnet.id
    route_table_id = aws_route_table.testroutetable.id
}

