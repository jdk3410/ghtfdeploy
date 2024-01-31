provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*22*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "tf_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "terraform-security"
  description = "Security group for Terraform autoprovision test. Inbound 22/80 open."
  vpc_id      = data.aws_vpc.default.id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "http-80-tcp"]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

resource "aws_instance" "instance" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  count         = var.instance_count

vpc_security_group_ids = [module.tf_sg.security_group_id]
  tags = {
    Name = var.instance_name
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get -y install nginx
              mkdir -p /var/www/html/
              echo "${var.instance_content}" > /var/www/html/index.html
              EOF 
             
}

