terraform {
    required_version = ">= 1.4.4"
}

locals {
    name = "<your name here>"
}

output "greeting" {
    value = "Hello, ${local.name}"
}
