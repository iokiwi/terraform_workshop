terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  # backend "s3" {
  #   bucket = "pstn-terraform-workshop-states"
  #   key = "reserved_instance"
  #   region = "ap-southeast-2"
  # }
}

provider "aws" {
  region = "ap-southeast-2"
}

# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}

data "aws_vpc" "default" {
    default = true
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_key_pair" "wordpress" {
    key_name = var.key_pair_name
}

data "aws_ebs_volume" "bsc_wordpress_data" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "tag:Name"
    values = ["bsc-wordpress"]
  }
}

resource "aws_iam_role" "wordpress" {
    name = "wordpress"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "wordpress_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.wordpress.name
}

locals {
  # https://www.cloudflare.com/ips/
  cloudflare_ips = [
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "108.162.192.0/18",
    "131.0.72.0/22",
    "141.101.64.0/18",
    "162.158.0.0/15",
    "172.64.0.0/13",
    "173.245.48.0/20",
    "188.114.96.0/20",
    "190.93.240.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17"
  ]

  # planetscale_ips = [
  #   "3.209.149.66/32",
  #   "3.215.97.46/32",
  #   "34.193.111.15/32",
  #   "3.24.39.244/32",
  #   "54.252.39.42/32",
  #   "54.253.218.226/32"
  # ]

  user_data = templatefile("./userdata.sh.tftpl", {
    server_name = var.server_name
    wordpress_db_user = var.wordpress_db_user,
    wordpress_db_pass = var.wordpress_db_pass,
    wordpress_db_host = var.wordpress_db_host,
    wordpress_db_name = var.wordpress_db_name,
    wordpress_db_charset = var.wordpress_db_charset,
    # mailgun_domain = var.mailgun_domain,
    # mailgun_api_key = var.mailgun_api_key,
    certbot_email = var.certbot_email,
  })
}

resource "aws_iam_instance_profile" "wordpress" {
    name = "wordpress"
    role = aws_iam_role.wordpress.name
}

resource "aws_security_group" "wordpress" {
  name        = "Wordpress Application"
  description = "Application Traffic from wordpress"
  vpc_id      = data.aws_vpc.default.id

  egress {
    description      = "SMTP out 25"
    from_port        = 25
    to_port          = 25
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }

  egress {
    description      = "SMTP out 465"
    from_port        = 465
    to_port          = 465
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }

  egress {
    description      = "SMTP out 587"
    from_port        = 587
    to_port          = 587
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }

  egress {
    description      = "MySQL to Planetscale DB"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [
      "0.0.0.0/0",
    ]
  }

  egress {
    description      = "HTTPS to Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }

  egress {
    description      = "HTTP to Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }

  ingress {
    description      = "SSH from Whitelisted Addresses"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.cidr_whitelist
  }

  ingress {
    description      = "HTTPS from Whitelisted Addresses"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.cidr_whitelist
  }

  ingress {
    description      = "HTTP from Whitelisted Adresses"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.cidr_whitelist
  }

  ingress {
    description      = "HTTPS from Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }

  ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
}

data "aws_eip" "wordpress" {
  filter {
    name   = "tag:Name"
    values = ["bsc-wordpress"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
# resource "aws_eip" "wordpress" {
# #   instance = aws_instance.wordpress.id
#   vpc      = true
# }

# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association
# resource "aws_eip_association" "wordpress" {
#   instance_id   = aws_instance.wordpress.id
#   allocation_id = aws_eip.wordpress.allocation_id
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.wordpress.id
  allocation_id = data.aws_eip.wordpress.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "wordpress" {
    ami           = data.aws_ami.ubuntu_latest.id
    instance_type = var.instance_type
    key_name = var.key_pair_name
    availability_zone = "ap-southeast-2a"

    user_data = local.user_data
    user_data_replace_on_change = true
    iam_instance_profile = aws_iam_instance_profile.wordpress.name
    vpc_security_group_ids = [ aws_security_group.wordpress.id ]

    tags = {
      Name = "bsc-wordpress"
    }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment
resource "aws_volume_attachment" "wordpress_data" {
  volume_id   = data.aws_ebs_volume.bsc_wordpress_data.id
  instance_id = aws_instance.wordpress.id
  device_name = "/dev/sde"
}

# output "userdata" {
#   value = local.user_data
# }
