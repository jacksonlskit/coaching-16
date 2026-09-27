# 1. Lookup the existing hosted zone in AWS
data "aws_route53_zone" "selected" {
  name         = "sctp-sandbox.com."
  private_zone = false
}

# 2. Create your group's record (e.g., group3.sctp-sandbox.com)
resource "aws_route53_record" "group3" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "group3.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 300
  records = ["203.0.113.10"] # Change to your target IP (or ALB/CloudFront)
}

# 3. Create a CNAME record (e.g., www.group3.sctp-sandbox.com)
resource "aws_route53_record" "group3_www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.group3.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = 300
  records = ["group3.${data.aws_route53_zone.selected.name}"]
}

# Output the Zone ID for reference
output "zone_id" {
  value = data.aws_route53_zone.selected.zone_id
}