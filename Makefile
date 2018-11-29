LOCAL_REGISTRY=gmt.reg.me/test
IMAGE_NAME=blueocean
IMAGE_TAG=latest
KUBECTL_BINARY_PATH=/usr/local/bin/kubectl
NAME=blueocean
NAMESPACE=gitlab
URL=gmt.je.me
IMAGE=${LOCAL_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
IMAGE_PULL_POLICY=Always
MANIFEST=./manifest
SCRIPT=./scripts
MOUNT_PATH=/var/jenkins_home
CLI_CONFIG=cli-config
LABELS_KEY=app
LABELS_VALUE=${NAME}

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
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.url}}"?"${URL}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image.pull.policy}}"?"${IMAGE_PULL_POLICY}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.kubectl.binary.path}}"?"${KUBECTL_BINARY_PATH}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.mount.path}}"?"${MOUNT_PATH}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.cli.config}}"?"${CLI_CONFIG}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.labels.key}}"?"${LABELS_KEY}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.labels.value}}"?"${LABELS_VALUE}"?g

deploy: export OP=create
deploy: cp sed
	-@kubectl ${OP} -f ${MANIFEST}/namespace.yaml
	@kubectl -n ${NAMESPACE} ${OP} configmap ${CLI_CONFIG} --from-file=config=/root/.kube/config
	@kubectl -n ${NAMESPACE} patch configmap ${CLI_CONFIG} -p '{"metadata": {"labels":{"${LABELS_KEY}":"${LABELS_VALUE}"}}}'
	@kubectl ${OP} -f ${MANIFEST}/pvc.yaml
	@kubectl ${OP} -f ${MANIFEST}/service.yaml
	@kubectl ${OP} -f ${MANIFEST}/controller.yaml
	@kubectl ${OP} -f ${MANIFEST}/ingress.yaml

clean: export OP=delete
clean:
	-@kubectl -n ${NAMESPACE} ${OP} all,svc,ing,pvc,cm -l ${LABELS_KEY}=${LABELS_VALUE} 
	-@rm -f ${MANIFEST}/service.yaml
	-@rm -f ${MANIFEST}/ingress.yaml
	-@rm -f ${MANIFEST}/namespace.yaml
	-@rm -f ${MANIFEST}/controller.yaml

passwd:
	@${SCRIPT}/get-passwd.sh -n ${NAME} -s ${NAMESPACE}

create-cm:
	@kubectl -n ${NAMESPACE} create configmap ${CLI_CONFIG} --from-file=config=/root/.kube/config

patch-cm:
	@kubectl -n ${NAMESPACE} patch configmap ${CLI_CONFIG} -p '{"metadata": {"labels":{"${LABELS_KEY}":"${LABELS_VALUE}"}}}'
