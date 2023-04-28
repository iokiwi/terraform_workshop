
variable "key_pair_name" {}
variable "certbot_email" {}

variable "cidr_whitelist" {
    type = set(string)
}

variable "server_name" {
    type = string
}

variable "ami_id" {
    # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type (Arm 64)
    default = "ami-0a9cfa40cedba2d5a"
}

# Note we have a 3 year ec2 cost saving plant for this instance type
variable "instance_type" {
    default = "t4g.small"
}

variable "capacity_reservation_id" {}

# variable "mysql_root" {}
variable "wordpress_db_host" {}
variable "wordpress_db_user" {}
variable "wordpress_db_pass" {}
variable "wordpress_db_name" {}
variable "wordpress_db_charset" {
    default  = "utf8mb4"
}

# variable "mailgun_api_key" {}
# variable "mailgun_domain" {}