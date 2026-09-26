terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Create the Public Hosted Zone
resource "aws_route53_zone" "primary" {
  name          = "sctp-sandbox.com"
  comment       = "Managed by Terraform"
  force_destroy = false

}

# 2. Standard 'A' Record (Static IP)
resource "aws_route53_record" "apex_a" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "sctp-sandbox.com"
  type    = "A"
  ttl     = 300
  records = ["203.0.113.10"]
}

# 3. 'CNAME' Record (Subdomain)
resource "aws_route53_record" "www_cname" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.sctp-sandbox.com"
  type    = "CNAME"
  ttl     = 300
  records = ["sctp-sandbox.com"]
}

# 4. Alias Record (e.g., pointing to an ALB or CloudFront)
# An alias record resolves directly to AWS resources without recurring DNS query costs
resource "aws_route53_record" "app_alias" {
  zone_id = aws_route53_zone.primary.group3
  name    = "app.sctp-sandbox.com"
  type    = "A"

  alias {
    name                   = "my-load-balancer-123456789.us-east-1.elb.amazonaws.com"
    zone_id                = "Z35SXDOTRQ7X7K" # Hosted zone ID of the AWS resource (e.g., ALB zone ID)
    evaluate_target_health = true
  }
}

# Outputs
output "name_servers" {
  description = "Name servers to configure at your domain registrar"
  value       = aws_route53_zone.primary.name_servers
}

output "zone_id" {
  description = "Zone ID of the created hosted zone"
  value       = aws_route53_zone.primary.zone_id
}