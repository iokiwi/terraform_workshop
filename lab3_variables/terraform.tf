terraform {
    required_version = ">= 1.4.4"
}

variable "name" {
    type = string
    description = "Your name, so we can greet you"
}

output "greeting" {
    value = "Hello, ${var.name}!"
}
