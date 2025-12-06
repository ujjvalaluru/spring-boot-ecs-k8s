DEFAULT_NAMESPACE="ujjval-macbook-java-apps"
DEFAULT_APP_NAME="users"
DEFAULT_LABEL_VERSION="NONE"
export NAMESPACE="${KUBERNETES_NAMESPACE:-$DEFAULT_NAMESPACE}"
export APP_NAME="${APP_NAME:-$DEFAULT_APP_NAME}"

CURR_SVC_VERSION=$(kubectl -n "$NAMESPACE" get svc "$APP_NAME-service"  -o jsonpath='{.spec.selector.version}' 2>/dev/null)

echo " service read $NAMESPACE $APP_NAME-service $CURR_SVC_VERSION"
export CURRENT_LABEL_VERSION="${CURR_SVC_VERSION:-$DEFAULT_LABEL_VERSION}"
export APP_NAME="${APP_NAME:-$DEFAULT_APP_NAME}"

mkdir -p ./deploy-temp-folder
{ kubectl create namespace $NAMESPACE ; } || true
envsubst < ./stable-service.yml > ./deploy-temp-folder/stable-service.yml
envsubst < ./network-policy.yml > ./deploy-temp-folder/network-policy.yml
kubectl apply -f ./deploy-temp-folder/ -n "$NAMESPACE"
