# Copyright (c) Tetrate, Inc 2022 All Rights Reserved.
.PHONY: help terraform-up terraform-down

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# Variables
ISTIO_VERSION       := 1.18.3
TF_DIR              := ./terraform
TF_PLAN_OUT         := terraform.plan

ROUTE53_HOSTED_ZONE      := internal.tetrate.io
KUBECONFIG               := output/kubeconfig.yaml
TERRAFORM_OUTPUT         := output/terraform.json
REDIS_DEFAULT_PASSWORD   := 2HZ41J9e6ts2O9Om24AQgC8ItyJJY6z2
REDIS_RATELIMIT_PASSWORD := l522s7e5o6QNxpzhTlgeeWJrmv6Ri4hq

HELM_CMD    := helm --kubeconfig ${KUBECONFIG}
KUBECTL_CMD := kubectl --kubeconfig ${KUBECONFIG}
TF_CMD      := terraform
TV_VARS			:= -var 'internal_zone=${ROUTE53_HOSTED_ZONE}' -var 'kubeconfig_file=${KUBECONFIG}' -var 'redis_default_password=${REDIS_DEFAULT_PASSWORD}' -var 'redis_ratelimit_password=${REDIS_RATELIMIT_PASSWORD}' 


terraform-up: ## Bring up aws infra with terraform
	@echo "Bring up aws infra using terraform..."
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) init"
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) validate"
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) fmt"

	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) plan -out=$(TF_PLAN_OUT) ${TV_VARS}"
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) apply $(TF_PLAN_OUT)"
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) output -json > ../${TERRAFORM_OUTPUT}"

terraform-down: ## Bring down aws infra with terraform
	@echo "Bring down aws infra using terraform..."
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) destroy"

refresh-k8s-token: ## Refresh eks kubectl kubeconfig token
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) apply -auto-approve -target=local_file.kubeconfig ${TV_VARS}"
	@echo "k9s --kubeconfig ${KUBECONFIG} -A"

istio-install: ## Install istio with helm
	@/bin/bash -c "helm repo add tetratelabs https://tetratelabs.github.io/helm-charts"
	@/bin/bash -c "helm repo update"
	@/bin/bash -c "${HELM_CMD} install istio-base tetratelabs/base -n istio-system --create-namespace --version ${ISTIO_VERSION} --wait || \
		(echo 'Install failed, attempting upgrade...' && \
		${HELM_CMD} upgrade istio-base tetratelabs/base -n istio-system --version ${ISTIO_VERSION} --wait)"
	@/bin/bash -c "${HELM_CMD} install istiod tetratelabs/istiod -n istio-system --version ${ISTIO_VERSION} --wait || \
		(echo 'Install failed, attempting upgrade...' && \
		${HELM_CMD} upgrade istiod tetratelabs/istiod -n istio-system --version ${ISTIO_VERSION} --wait)"
	@/bin/bash -c "${HELM_CMD} install istio-ingress tetratelabs/gateway -n istio-ingress --create-namespace --version ${ISTIO_VERSION} --wait || \
		(echo 'Install failed, attempting upgrade...' && \
		${HELM_CMD} upgrade istio-ingress tetratelabs/gateway -n istio-ingress --create-namespace --version ${ISTIO_VERSION} --wait)"

deploy-redis: refresh-k8s-token ## Deploy local redis and redis-cli
	@echo "Deploy local redis and redis-cli..."
	@/bin/bash -c "${KUBECTL_CMD} apply -f kubernetes/redis-cli.yaml"
	@/bin/bash -c "${KUBECTL_CMD} apply -f kubernetes/redis-local.yaml"

deploy-ratelimit: refresh-k8s-token ## Deploy local and remote connected ratelimit service
	@echo "Deploy local and remote connected ratelimit service..."
	@/bin/bash -c "${KUBECTL_CMD} apply -f kubernetes/ratelimit-config.yaml"
	@/bin/bash -c "${KUBECTL_CMD} apply -f kubernetes/ratelimit-local-redis.yaml"
	@/bin/bash -c "${KUBECTL_CMD} apply -f kubernetes/ratelimit-remote-elasticache.yaml"

	@echo "${KUBECTL_CMD} exec -n ratelimit -it $$(${KUBECTL_CMD} get pods -n ratelimit -l app=redis-cli -o jsonpath='{.items[0].metadata.name}') \
		-- redis-cli -h $$(jq -r '.redis_configuration_endpoint_address.value' output/terraform.json) \
		-p 6379	--tls -c --user ratelimit --pass ${REDIS_RATELIMIT_PASSWORD}"
	@echo "${KUBECTL_CMD} exec -n ratelimit -it $$(${KUBECTL_CMD} get pods -n ratelimit -l app=redis-cli -o jsonpath='{.items[0].metadata.name}') \
		-- redis-cli -h $$(jq -r '.redis_configuration_endpoint_address.value' output/terraform.json) \
		-p 6379	--tls -c --user default --pass ${REDIS_DEFAULT_PASSWORD}"
	@echo "${KUBECTL_CMD} exec -n ratelimit -it $$(${KUBECTL_CMD} get pods -n ratelimit -l app=redis-cli -o jsonpath='{.items[0].metadata.name}') \
		-- redis-cli -h redis.ratelimit.svc.cluster.local -p 6379"

deploy-httpbin: ## Deploy test application httpbin
	@echo "Deploy test application httpbin..."
	@/bin/bash -c "${KUBECTL_CMD} apply -f kubernetes/httpbin.yaml"
	@/bin/bash -c "${KUBECTL_CMD} apply -f kubernetes/httpbin-gateway.yaml"
	@echo "Single request..."
	@echo curl --resolve \"httpbin.tetrate.io:80:$$(dig +short $$(${KUBECTL_CMD} get services --namespace istio-ingress istio-ingress --output jsonpath='{.status.loadBalancer.ingress[0].hostname}') | head -n1)\" \"http://httpbin.tetrate.io/headers\"
	
