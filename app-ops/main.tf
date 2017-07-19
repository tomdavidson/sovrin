variable "app_name" {}

variable "tags" {
  default = {}
}

module "app_ops" {
  source = "git::https://gitlab.com/aws-config-stack/app-ops.git?ref=v0.3.0"
  name = "${var.app_name}"
  tags = "${var.tags}"
}
