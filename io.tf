variable "app_name" {
  type        = "string"
  description = "Name of the named resources"
}

variable "description" {
  default = ""

  description = <<EOF
(Optional)
Short description of the Application.
EOF
}

variable "tags" {
  default = {}

  description = <<EOF
(Optional)
A set of tags to apply to the Application's taggable reasouces. 
EOF
}
