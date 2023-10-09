#### provider Variables #######
variable "region" {
  type        = string
  description = "Name of the region to select"
  default     = "eu-west-2"
}

##### VPC Variables #######

variable "vpc_name" {
  type        = string
  description = "Name to be used on all the resources as identifier"
}
variable "public_subnets" {
  type        = list(string)
  description = "A list of public subnets inside the VPC"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "private_subnets" {
  type        = list(string)
  description = "A list of private subnets inside the VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "elasticache_subnets" {
  type        = list(string)
  description = "A list of elasticache subnets inside the VPC"
  default     = ["10.0.111.0/24", "10.0.112.0/24", "10.0.113.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "A list of availability zones specified as argument to this module"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}
variable "enable_nat_gateway" {
  type        = bool
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = "false"
}
variable "enable_vpn_gateway" {
  type        = bool
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = "false"
}

variable "one_nat_gateway_per_az" {
  type        = bool
  description = "Should be true if you want only one NAT Gateway per availability zone"
  default     = "false"
}
variable "enable_dns_hostnames" {
  type        = bool
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = "true"
}
variable "enable_dns_support" {
  type        = bool
  description = "Should be true to enable DNS support in the VPC"
  default     = "true"
}
variable "vpc_tags" {
  type = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}


##### EkS Cluster Variables #######
variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "eks_cluster_endpoint_private_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  default     = "true"
}
variable "eks_cluster_endpoint_public_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  default     = "false"
}
variable "eks_enable_irsa" {
  type        = bool
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  default     = "true"
}
variable "eks_tags" {
  type = map(string)
  default = {
    Environment = "dev"
  }
}

##### Elasticache Redis Cluster Variables #######
variable "redis_version" {
  type        = string
  description = "Version of the redis cluster"
}
variable "redis_parameter_group_name" {
  type        = string
  description = "Parameter group name of the redis cluster"
}
variable "redis_cluster_name" {
  type        = string
  description = "Name of the redis cluster"
}
variable "redis_default_password" {
  type        = string
  description = "Password of the redis admin user"
}
variable "redis_ratelimit_password" {
  type        = string
  description = "Password of the redis ratelimit user"
}

##### Istio Variables #######
variable "istio_version" {
  type        = string
  description = "Version of istio"
}
variable "istio_helm_repository" {
  type        = string
  description = "Helm repository of istio"
}
