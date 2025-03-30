resource "aws_network_interface" "testnic" {
    subnet_id = var.subnet_id
    private_ips = ["10.1.0.22"]
    security_groups = [var.security_group_id]
}