################################################################################
# VPC
################################################################################

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}
output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "VPC public subnets' IDs list"
}
output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "VPC private subnets' IDs list"
}

################################################################################
# EKS Cluster
################################################################################
output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}
output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.eks.cluster_status
}

output "cluster_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_security_group_id
}

################################################################################
# IRSA
################################################################################

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.oidc_provider_arn
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  value       = module.eks.cluster_tls_certificate_sha1_fingerprint
}


################################################################################
# Elasticache Redis Cluster
################################################################################
output "redis_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_elasticache_replication_group.default.arn
}

output "redis_configuration_endpoint_address" {
  description = "Address of the replication group configuration endpoint"
  value       = aws_elasticache_replication_group.default.configuration_endpoint_address
}

output "redis_primary_endpoint_address" {
  description = "Address of the endpoint for the primary node in the replication group"
  value       = aws_elasticache_replication_group.default.primary_endpoint_address
}

output "redis_reader_endpoint_address" {
  description = "Address of the endpoint for the reader node in the replication group"
  value       = aws_elasticache_replication_group.default.reader_endpoint_address
}

output "redis_cli_default" {
  description = "Redis cli command to test default user"
  value       = "redis-cli -h ${aws_elasticache_replication_group.default.configuration_endpoint_address} -p 6379 --user default --pass ${var.redis_default_password}"
}

output "redis_cli_ratelimit" {
  description = "Redis cli command to test ratelimit user"
  value       = "redis-cli -h ${aws_elasticache_replication_group.default.configuration_endpoint_address} -p 6379 --user ratelimit --pass ${var.redis_ratelimit_password}"
}

