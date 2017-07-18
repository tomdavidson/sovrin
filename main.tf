provider "aws" {
  region = "us-west-2"
}

resource "aws_eip" "public" {
  instance = "${aws_instance.validator.id}"
  vpc      = true
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
}

resource "aws_key_pair" "validator" {
  key_name   = "${var.name}"
  public_key = "${tls_private_key.default.public_key_openssh}"
}

module "cloud_config" {
  source = "./cloud-config"
}

resource "aws_instance" "validator" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.instance_size}"
  security_groups = ["${aws_security_group.sovrin.id}"]
  subnet_id       = "${var.subnet_id}"
  key_name        = "${aws_key_pair.validator.key_name}"
  user_data       = "${module.cloud_config.rendered}"
  tags            = "${merge(var.tags,var.required_tags, map("name", format("%s", var.name)))}"
}

resource "aws_efs_file_system" "default" {
  tags = "${merge(var.tags,var.required_tags, map("name", format("%s", var.name)))}"
}

resource "aws_efs_mount_target" "sovrin" {
  file_system_id = "${aws_efs_file_system.default.id}"
  subnet_id      = "${var.subnet_id}"
}

data "aws_subnet" "default" {
  id = "${var.subnet_id}"
}

resource "aws_security_group" "sovrin" {
  name        = "sovrin-new"
  description = "Allow inbound tcp on ports 9722 and 9711"

  ingress {
    from_port        = 9722
    to_port          = 9722
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 9711
    to_port          = 9711
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_subnet.default.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.tags,var.required_tags, map("name", format("%s", var.name)))}"
}
