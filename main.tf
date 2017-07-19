module "sovrin" {
  source = "other/sovrin-validator/node"

  app_name    = "${var.app_name}"
  description = "${var.description}"
  tags        = "${var.tags}"
}
