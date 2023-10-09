# Copyright (c) Tetrate, Inc 2022 All Rights Reserved.
.PHONY: help terraform-up terraform-down

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# Variables
TF_CMD      := terraform
TF_DIR      := ./terraform
TF_PLAN_OUT := terraform.plan

HELM_CMD 			:= helm --kubeconfig ${KUBECONFIG}
ISTIO_VERSION := 1.18.3

ROUTE53_HOSTED_ZONE := tetrate.internal
KUBECONFIG 					:= output/kubeconfig.yaml

terraform-up: ## Bring up aws infra with terraform
	@echo "Bring up aws infra using terraform..."
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) init"
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) validate"
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) fmt"

	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) plan -out=$(TF_PLAN_OUT) -var 'internal_zone=${ROUTE53_HOSTED_ZONE}' -var 'kubeconfig_file=${KUBECONFIG}'"
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) apply $(TF_PLAN_OUT)"

terraform-down: ## Bring down aws infra with terraform
	@echo "Bring down aws infra using terraform..."
	@/bin/bash -c "cd $(TF_DIR) && $(TF_CMD) destroy"

istio-install: ## Install istio with helm
	@/bin/bash -c "helm repo add tetratelabs https://tetratelabs.github.io/helm-charts"
	@/bin/bash -c "helm repo upgrade"
	@/bin/bash -c "helm install istio-base tetratelabs/base -n istio-system --create-namespace --version ${ISTIO_VERSION} --wait"
	@/bin/bash -c "helm install istiod tetratelabs/istiod -n istio-system --version ${ISTIO_VERSION} --wait || \
		helm upgrade istiod tetratelabs/istiod -n istio-system --version ${ISTIO_VERSION} --wait"
	@/bin/bash -c "helm install istio-ingress tetratelabs/gateway -n istio-ingress --create-namespace --version ${ISTIO_VERSION} --wait || \
		helm upgrade istio-ingress tetratelabs/gateway -n istio-ingress --create-namespace --version ${ISTIO_VERSION} --wait"

