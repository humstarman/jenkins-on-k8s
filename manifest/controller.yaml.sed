apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  namespace: {{.namespace}}
  name: {{.name}}
  labels:
    {{.labels.key}}: {{.labels.value}}
spec:
  serviceName: "{{.name}}"
  podManagementPolicy: Parallel
  replicas: 1
  template:
    metadata:
      labels:
        component: {{.name}}
        {{.labels.key}}: {{.labels.value}}
    spec:
      terminationGracePeriodSeconds: 10
      containers:
        - name: {{.name}}
          image: {{.image}} 
          imagePullPolicy: {{.image.pull.policy}} 
          env:
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
            - name: POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: JAVA_OPTS
              value: -Dorg.jenkinsci.plugins.gitclient.Git.timeOut=60
          volumeMounts:
            - name: host-time
              mountPath: /etc/localtime
              readOnly: true
            - mountPath: /var/run/docker.sock
              name: docker-socket
              readOnly: true
            - mountPath: /bin/kubectl
              name: kubectl-binary
              readOnly: true
            - mountPath: /root/.kube 
              name: kubectl-config-path
              readOnly: true
            - name: data 
              mountPath: {{.mount.path}}
      volumes:
        - name: host-time
          hostPath:
            path: /etc/localtime
        - name: docker-socket
          hostPath:
            path: /var/run/docker.sock
        - name: kubectl-binary
          hostPath:
            path: {{.kubectl.binary.path}}
        - name: kubectl-config-path
          configMap:
            name: {{.cli.config}}
        - name: data 
          persistentVolumeClaim:
            claimName: {{.name}}-data
