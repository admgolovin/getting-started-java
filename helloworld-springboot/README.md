# To launch configured jenkins-pod, please run this command:

helm install -n full-jenkins jenkins/ --set Master.CredentialsXmlSecret=credentials.xml,Master.SecretsFilesSecret={hudson.util.Secret,master.key}

Where:
   credentials.xml is your file from jenkins_home directory. This file is storing all credentials that you have been input in your Jenkins master pod.
   hudson.util.Secret and master.key are files which  necessary to allow new Jwnkins master to uncrypt your credentials.xml file.
