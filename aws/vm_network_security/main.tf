resource "aws_vpc" "testvpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "Test-VPC"
    }
}

resource "aws_subnet" "testsubnets" {
    for_each = var.subnets

    vpc_id = aws_vpc.testvpc.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az
    map_public_ip_on_launch = each.value.public

    tags = {
        Name = "${each.key}"
    }
}

resource "aws_internet_gateway" "testigw" {
    vpc_id = aws_vpc.testvpc.id

    tags = {
        Name = "Test-Igw"
    }
}

resource "aws_route_table" "publicrt" {
    for_each = { for k,v in aws_subnet.aws_subnet.testsubnets: k => v if v.map_public_ip_on_launch }

    vpc_id = aws_vpc.testvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.testigw.id
    }

    tags = {
        Name = "Public Route Table ${each.key}"
    }
}

resource "aws_route_table_association" "publicrta" {
    for_each = aws_route_table.public

    subnet_id = each.value.subnet_id
    route_table_id = each.value.id
}

resource "aws_security_group" "testsg" {
  name = "allow ssh"
  description = "Allow SSH access inbound traffic and all outbound traffic"
  vpc_id = aws_vpc.testvpc.id

  tags = {
    Name = "Allow_SSH"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
    security_group_id = aws_security_group.testsg.id
    cidr_ipv4 = "0.0.0.0/0"  #aws_vpc.testvpc.cidr_block
    ip_protocol = "tcp"
    to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.testsg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.testsg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}