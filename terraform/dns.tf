resource "aws_route53_zone" "internal_zone" {
  name    = "${var.internal_zone}."
  comment = "Internal hosted zone"
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "radis_dns" {
  zone_id = aws_route53_zone.internal_zone.zone_id
  name    = aws_elasticache_replication_group.default.configuration_endpoint_address
  type    = "CNAME"
  ttl     = "300"
  records = ["redis"]
}
