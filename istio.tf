resource "helm_release" "istio_base" {
  name             = "istio-base"
  namespace        = "istio-system"
  chart            = "base"
  create_namespace = true
  version          = var.istio_version
  repository       = var.istio_helm_repository
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  chart      = "istiod"
  version    = var.istio_version
  repository = var.istio_helm_repository

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name             = "istio-ingress"
  namespace        = "istio-ingress"
  chart            = "gateway"
  create_namespace = true
  version          = var.istio_version
  repository       = var.istio_helm_repository

  depends_on = [helm_release.istiod]
}

output "istio_version" {
  value = helm_release.istio_base.version
}
