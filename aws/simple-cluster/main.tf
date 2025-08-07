locals {
  services = {
    "ec2messages" : {
      "name" : "com.amazonaws.${var.region}.ec2messages"
    },
    "ssm" : {
      "name" : "com.amazonaws.${var.region}.ssm"
    },
    "ssmmessages" : {
      "name" : "com.amazonaws.${var.region}.ssmmessages"
    }
  }
}

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

resource "aws_iam_role" "ssm_role" {
    name = "TestSSMRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
        {
            Effect = "Allow",
            Principal = {
            Service = "ec2.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
    role       = aws_iam_role.ssm_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
    name = "TestSSMInstanceProfile"
    role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "private" {
    ami                    = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.testsubnet.id
    associate_public_ip_address = false
    key_name               = "my-key-pair"

    iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

    tags = {
        environment = "test"
    }
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  for_each = local.services
  vpc_id   = aws_vpc.testvpc.id
  service_name        = each.value.name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ssm_https.id]
  private_dns_enabled = true
  ip_address_type     = "ipv4"
  subnet_ids          = [aws_subnet.testsubnet.id]
}


