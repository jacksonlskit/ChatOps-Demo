data "aws_route53_zone" "this" {
    name = var.hosted_zone_name
    private_zone = false
  
}

resource "aws_route53_record" "this" {
    zone_id = data.aws_route53_zone.this.zone_id
    name    = var.record_name
    type    = "A"
    ttl     = 300
    records = [var.public_ip]


}