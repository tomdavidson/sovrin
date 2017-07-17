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

resource "aws_instance" "validator" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.instance_size}"
  security_groups = ["${aws_security_group.sovrin.id}"]
  subnet_id       = "${var.subnet_id}"
  key_name        = "${aws_key_pair.validator.key_name}"

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.default.private_key_pem}"
    }

    inline = [
      "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68DB5E88",
      "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BD33704C",
      "sudo apt update",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get install -yq software-properties-common python-software-properties",
      "sudo add-apt-repository \"deb https://repo.evernym.com/deb xenial stable\"",
      "sudo add-apt-repository \"deb https://repo.sovrin.org/deb xenial stable\"",
      "sudo apt update",
      "DEBIAN_FRONTEND=noninteractive sudo apt install -yq debsigs debsig-verify apt-transport-https python-pip python3-pip python3.5-dev libsodium18 sovrin-node",
      "sudo systemctl enable sovrin-node.service",
      "sudo systemctl status sovrin-node.service",
    ]
  }

  tags = "${merge(var.tags,var.required_tags, map("name", format("%s", var.name)))}"
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
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["128.187.116.26/32"]
  }

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
