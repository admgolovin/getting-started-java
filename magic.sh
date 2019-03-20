#!/bin/bash 
echo "Please, insert a name of your helm chart:"
read HELMNAME
echo "Your helm chart name is $HELMNAME"
helm install -n $HELMNAME $(pwd)/helloworld-springboot/jenkins/
POD_NAME=$(kubectl get pods | grep "$HELMNAME" | cut -d " " -f1 | sed s/' '//g )
POD_STATUS=$(kubectl get pods "$POD_NAME"  -o jsonpath="{.status.containerStatuses[0].ready}")
while [ "$POD_STATUS" != "true" ]
do
echo "Waiting for Jenkins POD creation, current creation status is: $POD_STATUS"
POD_STATUS=$(kubectl get pods "$POD_NAME"  -o jsonpath="{.status.containerStatuses[0].ready}")
done
JENKINSHOST=$(kubectl get service  $HELMNAME | grep $HELMNAME | cut -d " " -f10)
JENKINS_PASSWORD=Perform2018
echo "Your Jenkins connection link is http://$JENKINSHOST:8080/"
curl -s 'http://admin:'$JENKINS_PASSWORD'@'$JENKINSHOST':8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' > crumb.txt
set CRUMB=$(cat crumb.txt)
while ! [ -s $(pwd)/crumb.txt ]
do
curl 'http://admin:'$JENKINS_PASSWORD'@'$JENKINSHOST':8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' > crumb.txt
echo $CRUMB
sleep 1
done
CRUMB=$(head -n 1 crumb.txt)
echo "Now your crumb is $CRUMB"
echo "Please, insert your GIT username":
read GIT_USER
echo "Please, insert your GIT password:"
read GIT_PASSWORD
echo "Please, insert your AWS access key id:"
read AWS_ACCESS_KEY_ID
echo "Please, insert your AWS secret access key:"
read AWS_SECRET_ACCESS_KEY
curl -H $CRUMB -X POST 'http://admin:'$JENKINS_PASSWORD'@'$JENKINSHOST':8080/credentials/store/system/domain/_/createCredentials' \
--data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "Anton-GitHub",
    "username": "$GIT_USER",
    "password": "$GIT_PASSWORD",
    "description": "Credentials from github",
    "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }
}'
curl -H $CRUMB -X POST 'http://admin:'$JENKINS_PASSWORD'@'$JENKINSHOST':8080/credentials/store/system/domain/_/createCredentials' \
--data-urlencode 'json={ 
    "": "0", 
    "credentials": { 
        "scope": "GLOBAL", 
        "id": "antons-aws", 
        "description": "Antons aws account settings", 
        "accessKey": "$AWS_ACCESS_KEY_ID", 
        "secretKey": "$AWS_SECRET_ACCESS_KEY", 
        "iamRoleArn": "", 
        "iamMfaSerialNumber": "", 
        "$class": "com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl" 
    } 
}'