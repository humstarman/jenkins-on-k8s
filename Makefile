LOCAL_REGISTRY="10.254.0.50:5000"
IMAGE_NAME="blueocean"
IMAGE_TAG="latest"
KUBECTL_BINARY_PATH="/usr/local/bin/kubectl"
KUBECTL_CONFIG_PATH="/root/.kube"
NAME="blueocean"
NAMESPACE="gitlab"
IMAGE=${LOCAL_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
IMAGE_PULL_POLICY=Always
MANIFEST=./manifest
SCRIPT=./scripts

all: build push deploy

build:
	@docker build -t ${IMAGE} .

push:
	@docker push ${IMAGE}

cp:
	@find ${MANIFEST} -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.port}}"?"${PORT}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image}}"?"${IMAGE}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image.pull.policy}}"?"${IMAGE_PULL_POLICY}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.kubectl.binary.path}}"?"${KUBECTL_BINARY_PATH}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.kubectl.config.path}}"?"${KUBECTL_CONFIG_PATH}"?g

deploy: export OP=create
deploy: cp sed
	-@kubectl ${OP} -f ${MANIFEST}/namespace.yaml
	@kubectl ${OP} -f ${MANIFEST}/service.yaml
	@kubectl ${OP} -f ${MANIFEST}/controller.yaml
	@kubectl ${OP} -f ${MANIFEST}/ingress.yaml

clean:
	-@kubectl ${OP} -f ${MANIFEST}/service.yaml
	-@kubectl ${OP} -f ${MANIFEST}/ingress.yaml
	-@kubectl ${OP} -f ${MANIFEST}/configmap.yaml
	-@kubectl ${OP} -f ${MANIFEST}/controller.yaml
	-@rm -f ${MANIFEST}/service.yaml
	-@rm -f ${MANIFEST}/ingress.yaml
	-@rm -f ${MANIFEST}/configmap.yaml
	-@rm -f ${MANIFEST}/controller.yaml

refresh:
	@kubectl ${OP} -f ${MANIFEST}/configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/configmap.yaml

passwd:
	@${SCRIPT}/get-passwd.sh -n ${NAME} -s ${NAMESPACE}
