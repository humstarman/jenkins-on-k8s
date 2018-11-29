---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{.name}}-data
  namespace: {{.namespace}}
  labels:
    {{.labels.key}}: {{.labels.value}}
  annotations:
    volume.beta.kubernetes.io/storage-class: "slow"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
