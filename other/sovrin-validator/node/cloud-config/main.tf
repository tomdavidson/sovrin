variable "restart_window_seed" {
  default     = "9437349472623886"
  description = " "
}

variable "restart_window" {
  default     = "60"
  description = ""
}

data "template_file" "auto_updates" {
  template = "${file("${path.module}/auto-security-updates.yaml.tpl")}"

  vars {
    restart_window = "${var.restart_window_seed%var.restart_window}"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.auto_updates.rendered}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = "${file("${path.module}/sovrin.yaml")}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"

    content = <<EOF
final_message: "The system is finally up, after $UPTIME seconds"
output : { all : '| tee -a /var/log/cloud-init-output.log' }
EOF

    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}

output "rendered" {
  value = "${data.template_cloudinit_config.config.rendered}"
}
