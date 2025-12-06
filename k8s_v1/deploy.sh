
################################
###############################
####READ WEIGHTS AND INTERVALS
#################################
###############################
#!/bin/bash
# DEPLOYMENT 1
# DEFAULT_NAMESPACE="ujjval-macbook-java-apps"
# DEFAULT_APP_NAME="users"
# DEFAULT_VERSION="v1"
# DEFAULT_VERSION_LABEL="V1"
# DEFAULT_CURRENT_VERSION="none"
# DEFAULT_CURRENT_VERSION_LABEL="NONE"
# DEFAULT_IMAGE="user-app:1.0"
# DEFAULT_SPRING_PROFILE="local-docker"
# DEFAULT_JAVA_OPTS="-Xms512m -Xmx1024m"
# DEFAULT_READINESS_PATH="/actuator/health"
# DEFAULT_LIVENESS_PATH="/actuator/info"
# DEFAULT_WEIGHTS=(10 50 70)
# DEFAULT_INTERVAL=(60 120 180)

#DEPLOYMENT 2
# DEFAULT_NAMESPACE="ujjval-macbook-java-apps"
# DEFAULT_APP_NAME="users"
# DEFAULT_VERSION="v2"
# DEFAULT_VERSION_LABEL="V2"
# DEFAULT_CURRENT_VERSION="v1"
# DEFAULT_CURRENT_VERSION_LABEL="V1"
# DEFAULT_IMAGE="user-app:2.0"
# DEFAULT_SPRING_PROFILE="local-docker"
# DEFAULT_JAVA_OPTS="-Xms512m -Xmx1024m"
# DEFAULT_READINESS_PATH="/actuator/health"
# DEFAULT_LIVENESS_PATH="/actuator/info"
# DEFAULT_WEIGHTS=(10 50 70)
# DEFAULT_INTERVAL=(60 120 180)

#DEPLOYMENT 3
DEFAULT_NAMESPACE="ujjval-macbook-java-apps"
DEFAULT_APP_NAME="users"
DEFAULT_VERSION="v3"
DEFAULT_VERSION_LABEL="V3"
DEFAULT_CURRENT_VERSION="v1"
DEFAULT_CURRENT_VERSION_LABEL="V1"
DEFAULT_IMAGE="user-app:1.0"
DEFAULT_SPRING_PROFILE="local-docker"
DEFAULT_JAVA_OPTS="-Xms512m -Xmx1024m"
DEFAULT_READINESS_PATH="/actuator/health"
DEFAULT_LIVENESS_PATH="/actuator/info"
DEFAULT_WEIGHTS=(10 50 70)
DEFAULT_INTERVAL=(60 120 180)

export APP_NAME="${APP_NAME:-$DEFAULT_APP_NAME}"
export NAMESPACE="${KUBERNETES_NAMESPACE:-$DEFAULT_NAMESPACE}"
export VERSION="${VERSION:-$DEFAULT_VERSION}"
export VERSION_LABEL="${VERSION_LABEL:-$DEFAULT_VERSION_LABEL}"
export DOCKER_IMAGE="${DOCKER_IMAGE:-$DEFAULT_IMAGE}"
export SPRING_PROFILE="${SPRING_PROFILE:-$DEFAULT_SPRING_PROFILE}"
export JAVA_OPTS="${JAVA_OPTS:-$DEFAULT_JAVA_OPTS}"
export READINESS_PATH="${READINESS_PATH:-$DEFAULT_READINESS_PATH}"
export LIVENESS_PATH="${LIVENESS_PATH:-$DEFAULT_LIVENESS_PATH}"

# Read version from the service selector
CURR_SVC_VERSION=$(kubectl -n "$NAMESPACE" get svc "$APP_NAME"-service \
          -o jsonpath='{.spec.selector.version}' 2>/dev/null)
export CURRENT_VERSION_LABEL="${CURR_SVC_VERSION:-$DEFAULT_CURRENT_VERSION_LABEL}"
export CURRENT_VERSION="${CURRENT_VERSION:-$DEFAULT_CURRENT_VERSION}"




do_patch_canary_rollout_action() {
  base_weight=$1
  canary_weight=$2
  echo "Patching HTTPProxy to set base weight to $base_weight and canary weight to $canary_weight"
  kubectl -n "$NAMESPACE" patch httpproxy "$APP_NAME"-service-proxy \
  --type='merge' \
  -p "{
      \"spec\": {
        \"routes\": [
          {
            \"conditions\": [
              { \"prefix\": \"/\" }
            ],
            \"services\": [
              { \"name\": \"$APP_NAME-service\", \"port\": 80, \"weight\": $base_weight },
              { \"name\": \"$APP_NAME-service-$VERSION\", \"port\": 80, \"weight\": $canary_weight }
            ]
          }
        ]
      }
    }"
  
}

do_rollback_action(){
  echo "Rolling back to previous stable version $CURRENT_VERSION"
  echo "Patching HTTPProxy to route 100% traffic to stable service"
 kubectl -n "$NAMESPACE" patch httpproxy "$APP_NAME"-service-proxy \
  --type='merge' \
  -p "{
      \"spec\": {
        \"routes\": [
          {
            \"conditions\": [
              { \"prefix\": \"/\" }
            ],
            \"services\": [
              { \"name\": \"$APP_NAME-service\", \"port\": 80, \"weight\": 100 }
            ]
          }
        ]
      }
    }"
   echo "deleting canary deployment $APP_NAME-$VERSION"
   kubectl -n "$NAMESPACE" delete deployment "$APP_NAME"-"$VERSION"
   echo "deleting canary service $APP_NAME-service-$VERSION"
   kubectl -n "$NAMESPACE" delete service "$APP_NAME"-service-"$VERSION"
}

do_stabilize_new_app(){

 echo "Stabilizing app by switching service selector label to version $VERSION_LABEL"
 kubectl -n "$NAMESPACE" patch svc "$APP_NAME"-service \
  --type='json' \
  -p="[{\"op\": \"replace\", \"path\": \"/spec/selector/version\", \"value\": \"$VERSION_LABEL\"}]"

  echo "Stabilizing app by switching httpproxy service selector to live service only"
  kubectl -n "$NAMESPACE" patch httpproxy "$APP_NAME"-service-proxy \
  --type='merge' \
  -p "{
      \"spec\": {
        \"routes\": [
          {
            \"conditions\": [
              { \"prefix\": \"/\" }
            ],
            \"services\": [
              { \"name\": \"$APP_NAME-service\", \"port\": 80, \"weight\": 100 }
            ]
          }
        ]
      }
    }"

    echo "deleting old deployment from $CURRENT_VERSION"
    kubectl -n "$NAMESPACE" delete deployment "$APP_NAME"-"$CURRENT_VERSION" 

    echo "deleting canary service user-service-$VERSION"
    kubectl -n "$NAMESPACE" delete service "$APP_NAME"-service-"$VERSION" 

}


echo "enter array of weights"
read -a weights 
# If no input → use default
if [ ${#weights[@]} -eq 0 ]; then
  weights=("${DEFAULT_WEIGHTS[@]}")
fi
echo "enter array of time intervals in seconds"
read -a time_intervals
# If no input → use default
if [ ${#time_intervals[@]} -eq 0 ]; then
  time_intervals=("${DEFAULT_INTERVAL[@]}")
fi

echo "Final array:"
printf "weights %s\n" "${weights[@]}"

printf "intervals %s\n" "${time_intervals[@]}"


################################
###############################
####DEPLOY CANARY WITHOUT TRAFFIC (DEPLOYMENT, SERVICE, HTTPPROXY)
#################################
###############################

envsubst < ./canary-deployment/service.yml > ./deploy-temp-folder/canary-service.yml
envsubst < ./canary-deployment/deployment.yml > ./deploy-temp-folder/canary-deployment.yml
envsubst < ./canary-deployment/http-proxy.yml > ./deploy-temp-folder/http-proxy.yml

echo "Deploying canary service"
kubectl apply -f ./deploy-temp-folder/canary-service.yml -n "$NAMESPACE"
echo "creating canary deployment"
kubectl apply -f ./deploy-temp-folder/canary-deployment.yml -n "$NAMESPACE"
echo "creating/updating HTTPProxy for canary deployment"
kubectl apply -f ./deploy-temp-folder/http-proxy.yml -n "$NAMESPACE"


################################
###############################
####PERFORM TRAFFIC SPLITTING BASED ON WEIGHTS AND INTERVALS BY PATCHING HTTP PROXY
#################################
###############################


for ((i=0; i<${#weights[@]}; i++)); do
  echo "performing patch with weight ${weights[$i]} and waiting for ${time_intervals[$i]} seconds \n"
  read -p "Do you want to continue? (y/n): " answer
  w="${weights[$i]}"
  base_weight=$((100 - w))
  case "$answer" in
    y|Y|yes|YES)
        do_patch_canary_rollout_action $base_weight $w
        sleep ${time_intervals[$i]}
        ;;
    n|N|no|NO)
        do_rollback_action
        ;;
    *)
        echo "Invalid input. Please enter y or n."
        ;;
   esac
done



################################
###############################
#### CHECK IF USER WANTS TO STABILIZE OR ROLLBACK
#################################
###############################
read -p "Do you want to FINISH DEPLOYMENT BY STABILIZING NEW APP? (y/n): " CONTINUEROLLBACK
case "$CONTINUEROLLBACK" in
  y|Y|yes|YES)
      do_stabilize_new_app
      ;;
  n|N|no|NO)
      do_rollback_action
      ;;
  *)
      echo "Invalid input. Please enter y or n."
      ;;
 esac 
################################










