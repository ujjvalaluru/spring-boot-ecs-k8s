### STARt or STOP POSTGRES DB in local
sudo -u postgres /Library/PostgreSQL/17/bin/pg_ctl -D /Library/PostgreSQL/17/data stop
sudo -u postgres /Library/PostgreSQL/17/bin/pg_ctl -D /Library/PostgreSQL/17/data start

### building jar for local docker or kubernetes cluster oe ECS
mvn -Dmaven.repo.local=/Users/ujjvalaluru/Documents/back_2_coding/Java/maven_projects/postgres-rds-test clean install


### running project standalone
mvn -Dmaven.repo.local=/Users/ujjvalaluru/Documents/back_2_coding/Java/maven_projects/postgres-rds-test spring-boot:run -Dspring-boot.run.jvmArguments=\"-Dspring.profiles.active=local\"

### KUBERNETES DEPLOYMENT INSTRUCTIONS for local
### build docker image for local
docker build -t user-app:2.0 .
cd k8s_v1

### update below parameters in pre-deploy.sh as Per version
DEFAULT_NAMESPACE="ujjval-macbook-java-apps"
DEFAULT_APP_NAME="users"
DEFAULT_LABEL_VERSION="NONE"
./pre-deploy.sh

### update below parameters in deploy.sh as Per version

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

./deploy.sh



### accessing application
curl -X GET http://s1/users/findByName/Ujjval
curl -X GET http://s1/users/1234



### BUILDING AND PUSHING JAR to ECR repository
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 106207520156.dkr.ecr.us-east-1.amazonaws.com
docker buildx build --platform linux/arm64 -t 106207520156.dkr.ecr.us-east-1.amazonaws.com/ujjval-users:0.5 --push .

