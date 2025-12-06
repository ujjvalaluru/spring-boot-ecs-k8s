
kubectl -n ujjval-macbook-java-apps delete service users-service
kubectl -n ujjval-macbook-java-apps delete service users-service-v1
kubectl -n ujjval-macbook-java-apps delete deployment users-v1
kubectl -n ujjval-macbook-java-apps delete HTTPProxy users-service-proxy
kubectl -n ujjval-macbook-java-apps delete networkpolicy users-allow-contour-envoy

kubectl -n ujjval-macbook-java-apps delete service users-service-v2
kubectl -n ujjval-macbook-java-apps delete deployment users-v2
kubectl -n ujjval-macbook-java-apps delete HTTPProxy users-service-proxy
kubectl -n ujjval-macbook-java-apps delete networkpolicy users-allow-contour-envoy

rm -rf ./deploy-temp-folder
kubectl delete namespace ujjval-macbook-java-apps || true

