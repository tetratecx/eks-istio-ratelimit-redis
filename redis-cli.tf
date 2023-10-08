resource "kubernetes_deployment" "redis_cli" {
  metadata {
    name      = "redis-cli"
    namespace = "default"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis-cli"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis-cli"
        }
      }

      spec {
        container {
          name  = "redis-cli"
          image = "redis:alpine"

          command = ["sleep"]
          args    = ["infinity"]
        }
      }
    }
  }
}
