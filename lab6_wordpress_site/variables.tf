variable "certbot_email" {
  type        = string
  description = "Your email address to register with Letsencrypt/Certbot. It's required to accept the TOS and get notifcations about certificate lifecycle events."
}

variable "privileged_ip_address" {
  type        = string
  description = "An ip address which is allowed to access to the inital installation wizard screen which does not require authentication. Use your current IP address which can be found by running 'curl https://icanhazip.com'"

  # https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules
  validation {
    condition     = var.privileged_ip_address != "0.0.0.0"
    error_message = "The IP address cannot be 0.0.0.0"
  }
}

variable "availability_zone" {
  default = "ap-southeast-2a"
}

variable "namespace" {
  type        = string
  description = "A string to distinguish your resources from those of others in the same AWS account. Your name might be an appropriate value"
}

variable "domain" {
  type        = string
  description = "The TLD of the application"
}

variable "instance_type" {
  default = "t4g.small"
}

variable "wordpress_db_host" {}
variable "wordpress_db_user" {}
variable "wordpress_db_pass" {}
variable "wordpress_db_name" {}
variable "wordpress_db_charset" {
  default = "utf8mb4"
}
