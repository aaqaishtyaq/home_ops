
## Setting up the cluster

```console
kind create cluster --config kind.yaml

# Deploy nginx ingress
kubectl apply -f deploy-nginx.yaml

# Wait until is ready to process requests running
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```
