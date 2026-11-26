variable "aws_region" { type = string }
variable "subnet_id" { type = string }
variable "security_group_id" { type = string }
variable "waldur_resource_uuid" { type = string }
variable "instance_name" {
  type = string
  validation {
    condition = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$", var.instance_name))
    error_message = "Alphanumeric and hyphens only, max 63 characters."
  }
}
variable "instance_type" {
  type = string
  validation {
    condition = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Only approved POC instance types allowed."
  }
}
