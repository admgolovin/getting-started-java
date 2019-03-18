kubectl edit ing node-js-app << EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  creationTimestamp: "2019-03-17T18:27:21Z"
  generation: 1
  labels:
    app.kubernetes.io/instance: js-app
    app.kubernetes.io/managed-by: Tiller
    app.kubernetes.io/name: js-app
    helm.sh/chart: js-app-0.1.0
  name: node-js-app
  namespace: default
  resourceVersion: "1470697"
  selfLink: /apis/extensions/v1beta1/namespaces/default/ingresses/node-js-app
  uid: 4dfb9467-48e2-11e9-b85d-0a7d98e3957c
spec:
  rules:
  - host: js-app-demo.stark-net.com
    http:
      paths:
      - backend:
          serviceName: node-js-app-blue
          servicePort: 8181
        path: /
  - host: js-app.stark-net.com
    http:
      paths:
      - backend:
          serviceName: node-js-app-green
          servicePort: 8181
        path: /
status:
  loadBalancer:
    ingress:
    - ip: 18.197.150.174
EOF