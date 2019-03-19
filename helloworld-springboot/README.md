# To launch configured jenkins-pod, please run this command:

set CRUMB=$(curl -s 'http://admin:Slider256$@a2711abcc4a5c11e99bb80a7d98e3957-1537647075.eu-central-1.elb.amazonaws.com:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')

export GIT_PASSWORD="Your git password"
export GIT_USER="Your GIT user"

export AWS_SECRET_ACCESS_KEY="Your aws secret"
export AWS_ACCESS_KEY_ID="Your aws access key id"

export JENKINS_PASSWORD="Your jenkins password"

curl -H $CRUMB -X POST 'http://admin:$JENKINS_PASSWORD@a2711abcc4a5c11e99bb80a7d98e3957-1537647075.eu-central-1.elb.amazonaws.com:8080/credentials/store/system/domain/_/createCredentials' \
--data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "Anton-GitHub",
    "username": $GIT_USER,
    "password": $GIT_PASSWORD,
    "description": "My Git",
    "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }
}'

curl -H $CRUMB -X POST 'http://admin:$JENKINS_PASSWORD@a2711abcc4a5c11e99bb80a7d98e3957-1537647075.eu-central-1.elb.amazonaws.com:8080/credentials/store/system/domain/_/createCredentials' \
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
