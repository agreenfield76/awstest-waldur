resource "aws_instance" "research" {
  ami                    = "ami-07bf19f3b07fa1602"
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  metadata_options { http_tokens = "required" }
  root_block_device {
    encrypted = true
    volume_size = 20
    volume_type = "gp3"
  }
  tags = {
    Name = var.instance_name
    WaldurResourceUUID = var.waldur_resource_uuid
  }
}
