resource "aws_elasticache_replication_group" "default" {
  replication_group_id = var.redis_cluster_name
  description          = "Redis cluster for Hashicorp ElastiCache example"

  auth_token                 = var.redis_admin_password
  automatic_failover_enabled = true
  node_type                  = "cache.m4.large"
  num_node_groups            = 2
  parameter_group_name       = "default.redis7.cluster.on"
  port                       = 6379
  replicas_per_node_group    = 1
  subnet_group_name          = var.redis_cluster_name
  transit_encryption_enabled = true
}

resource "aws_elasticache_user" "ratelimit" {
  user_id       = "ratelimit"
  user_name     = "ratelimit"
  access_string = "on ~* +@all"
  engine        = "REDIS"
  passwords     = ["${var.redis_ratelimit_password}"]
}