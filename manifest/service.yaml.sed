apiVersion: v1
kind: Service
metadata:
  namespace: {{.namespace}} 
  labels:
    proxy: {{.name}}
    {{.labels.key}}: {{.labels.value}}
  name: {{.name}}
spec:
  type: ClusterIP
  ports:
  - name: http 
    port: 80 
    targetPort: 8080
  selector:
    component: {{.name}}
