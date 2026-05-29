helm install karpenter . \
  -f karpenter-values.yaml \
  -n karpenter \
  --create-namespace

helm install ingress-nginx ingress-nginx/ingress-nginx -f custom-values.yaml -n nginx-ingress --create-namespace