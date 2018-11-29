apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{.name}}-ingress
  namespace: {{.namespace}}
  labels:
    {{.labels.key}}: {{.labels.value}}
spec:
  rules:
  - host: {{.url}} 
    http:
      paths:
      - path: /
        backend:
          serviceName: {{.name}} 
          servicePort: 80
