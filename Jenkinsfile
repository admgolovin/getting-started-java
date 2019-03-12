def branch
def revision
def registryIp

pipeline {

    agent {
        kubernetes {
            label 'build-service-pod'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    job: build-service
spec:
  containers:
  - name: jnlp
    image: jenkins/jnlp-slave:alpine
    volumeMounts:
    - mountPath: /home/jenkins
      name: workspace-volume
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-cd85g
      readOnly: true
    resources:  
      requests:
        ephemeral-storage: "100Mi"
      limits:
        ephemeral-storage: "2Gi"
  - name: maven
    image: maven:3.6-jdk-8-slim
    command: ["cat"]
    tty: true
    resources:
      requests:
        ephemeral-storage: "100Mi"
      limits:
        ephemeral-storage: "2Gi"
    volumeMounts:
    - name: repository
      mountPath: /root/.m2/repository
  - name: docker
    image: docker:18.09.2
    command: ["cat"]
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
    resources:
      limits:
        ephemeral-storage: "2Gi"
      requests:
        ephemeral-storage: "100Mi"

  volumes:
  - name: repository
    persistentVolumeClaim:
      claimName: repository
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }
    options {
        skipDefaultCheckout true
    }


    stages ('Tests'){

        stage ('checkout') {
            steps{
                script{
                    print "Checkout stage is launched"
                    def mycommit = checkout scm
                    for (val in mycommit) {
                        print "key = ${val.key}, value = ${val.value}"
                    }
                    revision = sh(script: 'git log -1 --format=\'%h.%ad\' --date=format:%Y%m%d-%H%M | cat', returnStdout: true).trim()

                }
            }
        }
        stage ('build and push artifact') {
            steps {
                container('maven') {
                    sh 'ls -a'
                    sh 'cd helloworld-springboot/'
                    sh "mvn package -Dmaven.test.skip -Drevision=${revision}"
                }
                container('docker') {
                    script {
                        registryIp= "818353068367.dkr.ecr.eu-central-1.amazonaws.com/tony"
                        sh "docker build . -t ${registryIp}:${revision} --build-arg REVISION=${revision}"
                        docker.withRegistry("https://818353068367.dkr.ecr.eu-central-1.amazonaws.com", "ecr:eu-central-1:antons-aws") {
                            sh "docker push ${registryIp}:${revision}"
                        }   
                    }
                }
            }
        }
        stage ('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage ('Deploy artifact to production'){
          agent{
            kubernetes{
              label 'helm-chart-pod'
              defaultContainer 'jnlp'
              yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    job: deploy-service
spec:
  containers:
  - name: git
    image: alpine/git
    command: ["cat"]
    tty: true
  - name: helm-cli
    image: ibmcom/k8s-helm:v2.6.0
    env:
    - name: rnumber
      value: ${revision}
    command: ["cat"]
    tty: true
"""

          }
        }
          steps{
            container('git'){
              sh "git clone https://github.com/admgolovin/getting-started-java"
              sh "ls -a"
            }
            container('helm-cli'){
              sh "ls -a"
              sh "env"
              dir('getting-started-java/helloworld-springboot'){
                sh "envsubst < MyApp/values.yaml > values.yaml"
                sh "cat values.yaml"
                sh "cp values.yaml MyApp/values.yaml"
                sh "helm install MyApp"
              }
            }
          }
        }
    }
}
