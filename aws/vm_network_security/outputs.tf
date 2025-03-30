output "vpc_id" {
  value = aws_vpc.testvpc.id
}

output "public_subnet_ids" {
    value = [for s in aws_subnet.testsubnets: s.id if s.map_public_ip_on_launch]
}