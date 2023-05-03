terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = {
      Namespace = "${var.namespace}"
      Name      = "${var.namespace}-wordpress"
    }
  }
}

# If you are using the paystation-oos-test account
data "aws_vpc" "default" {
  default = false
}

data "aws_subnet" "public" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.availability_zone
  filter {
    name   = "tag:Name"
    values = ["PublicSubnet*"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data/route53_zone
data "aws_route53_zone" "primary" {
  name = "${var.domain}."
}

resource "aws_route53_record" "wordpress" {
  # zone_id = aws_route53_zone.primary.zone_id
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.fqdn
  type    = "A"
  ttl     = 5
  records = [aws_eip.wordpress.public_ip]
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

resource "aws_iam_role" "wordpress" {
  name = "${var.namespace}-wordpress"
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

resource "aws_iam_role_policy_attachment" "wordpress_allow_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.wordpress.name
}

locals {
  fqdn = "${var.namespace}.${var.domain}"
  user_data = templatefile("./userdata.sh.tftpl", {
    namespace             = var.namespace,
    fqdn                  = local.fqdn,
    privileged_ip_address = var.privileged_ip_address
    wordpress_db_user     = var.wordpress_db_user,
    wordpress_db_pass     = var.wordpress_db_pass,
    wordpress_db_host     = var.wordpress_db_host,
    wordpress_db_name     = var.wordpress_db_name,
    wordpress_db_charset  = var.wordpress_db_charset,
    certbot_email         = var.certbot_email,
  })
}

resource "aws_iam_instance_profile" "wordpress" {
  name = "${var.namespace}-wordpress"
  role = aws_iam_role.wordpress.name
}

resource "aws_security_group" "wordpress" {
  name        = "${var.namespace}-wordpress"
  description = "Application Traffic from wordpress"
  vpc_id      = data.aws_vpc.default.id

  egress {
    description = "HTTPS to Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP to Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume
resource "aws_ebs_volume" "wordpress_data" {
  availability_zone = var.availability_zone
  size              = 10
  encrypted         = true
  type              = "gp2"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "wordpress" {
  vpc = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.wordpress.id
  allocation_id = aws_eip.wordpress.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "wordpress" {
  ami                         = data.aws_ami.ubuntu_latest.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.public.id
  availability_zone           = var.availability_zone
  user_data                   = local.user_data
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.wordpress.name
  vpc_security_group_ids      = [aws_security_group.wordpress.id]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment
resource "aws_volume_attachment" "wordpress_data" {
  volume_id   = aws_ebs_volume.wordpress_data.id
  instance_id = aws_instance.wordpress.id
  device_name = "/dev/sde"
}

output "public_ip_address" {
  value = aws_eip.wordpress.public_ip
}

output "url" {
  value = "https://${local.fqdn}"
}

# # [BYOA] - Uncomment this
# output "dns_record" {
#   value = "Please ensure the following DNS record exsits: (Type: A) ${local.fqdn} -> ${aws_eip.wordpress.public_ip}"
# }
