## Setup
region = "eu-west-2"

#### VPC ###
vpc_name           = "eks-istio-redis"
enable_nat_gateway = true
enable_vpn_gateway = true

### EKS Cluster ##
eks_cluster_name                    = "eks-istio-redis"
eks_cluster_endpoint_private_access = true
eks_cluster_endpoint_public_access  = true

### Redis Cluster ##
redis_version              = "6.2"
redis_parameter_group_name = "default.redis6.x.cluster.on"
# redis_parameter_group_name = "default.redis7.cluster.on"
redis_cluster_name       = "eks-istio-redis"
redis_default_password   = "2HZ41J9e6ts2O9Om24AQgC8ItyJJY6z2"
redis_ratelimit_password = "l522s7e5o6QNxpzhTlgeeWJrmv6Ri4hq"
