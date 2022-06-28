#!/usr/bin/env bash
set -e

echo "Waiting for dataflow"
kubectl rollout status deployment scdf-server

kubectl port-forward --namespace default svc/scdf-server "9393:9393" &
if [ "$PROMETHEUS" == "true" ]; then
  kubectl port-forward --namespace default svc/grafana "3000:3000" &
fi

export DATAFLOW_IP="http://localhost:9393"
echo "DATAFLOW_IP=$DATAFLOW_IP"
