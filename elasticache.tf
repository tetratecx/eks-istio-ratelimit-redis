resource "aws_security_group" "elasticache" {
  vpc_id = module.vpc.vpc_id
  name   = "ElastiCache Security Group"

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ElastiCache Security Group"
  }
}

resource "aws_network_acl" "elasticache" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.elasticache_subnets

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 6379
    to_port    = 6379
  }

  tags = {
    Name = "ElastiCache Network ACL"
  }
}

resource "aws_elasticache_replication_group" "default" {
  replication_group_id = var.redis_cluster_name
  description          = "Redis cluster for Hashicorp ElastiCache example"

  automatic_failover_enabled = true
  node_type                  = "cache.m4.large"
  num_node_groups            = 2
  parameter_group_name       = "default.redis7.cluster.on"
  port                       = 6379
  replicas_per_node_group    = 1
  security_group_ids         = [aws_security_group.elasticache.id]
  subnet_group_name          = var.redis_cluster_name
  transit_encryption_enabled = true
  user_group_ids             = [aws_elasticache_user_group.istio.id]
}

resource "aws_elasticache_user" "default" {
  user_id       = "istio-default"
  user_name     = "default"
  access_string = "on ~* +@all"
  engine        = "REDIS"
  passwords     = [var.redis_default_password]
}

resource "aws_elasticache_user" "ratelimit" {
  user_id       = "istio-zratelimit"
  user_name     = "ratelimit"
  access_string = "on ~* +@all"
  engine        = "REDIS"
  passwords     = [var.redis_ratelimit_password]
}

resource "aws_elasticache_user_group" "istio" {
  engine        = "REDIS"
  user_group_id = "istio"
  user_ids      = [aws_elasticache_user.default.user_id, aws_elasticache_user.ratelimit.user_id]

  lifecycle {
    ignore_changes = [user_ids]
  }
}