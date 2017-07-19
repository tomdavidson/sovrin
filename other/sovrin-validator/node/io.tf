variable "instance_size" {
  default     = "t2.small"
  description = "Size of the EC2 instance"
}

variable "name" {
  default = "sovrin"
}

variable "required_tags" {
  type = "map"

  default = {
    "provisioner" = "terraform"
  }
}

variable "tags" {
  type = "map"

  default = {}
}

variable "subnet_id" {
  default = "subnet-42e7a226"
}
