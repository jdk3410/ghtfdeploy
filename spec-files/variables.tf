variable "instance_name" {
  description = "Name of the EC2 instance"
}

variable "instance_content" {
  description = "Content for the Hello World webpage"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  default     = 1
}

variable "region" {
  description = "The region Terraform deploys your instance"
  default     = "us-east-2"
}
