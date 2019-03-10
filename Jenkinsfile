def branch
def revision
def registryIp

pipeline {

    agent {
        kubernetes {
            label 'build-service-pod'
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    job: build-service
spec:
  containers:
  - name: maven
    image: maven:3.6-jdk-8-slim
    command: ["cat"]
    tty: true
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
                    revision = sh(script: 'git log -1 --format=\'%h.%ad\' --date=format:%Y%m%d-%H%M | cat', returnStdout: true).trim()

                    }
                }
            }
        }
        stage ('compile') {
            steps {
                container('maven') {
                    sh 'ls -a'
                    sh 'cd helloworld-springboot'
                    sh 'mvn clean compile test-compile'
                }
            }
        }
        stage ('unit test') {
            steps {
                container('maven') {
                    sh 'mvn test'
                }
            }
        }
        stage ('integration test') {
            steps {
                container ('maven') {
                    sh 'mvn verify'
                }
            }
        }
        stage ('build and push artifact') {
            steps {
                container('maven') {
                    sh "mvn package -Dmaven.test.skip -Drevision=${revision}"
                }
                container('docker') {
                    script {
                        registryIp= "https://818353068367.dkr.ecr.eu-central-1.amazonaws.com/tony"
           
                        sh "docker build . -t ${registryIp}/demo/app:${revision} --build-arg REVISION=${revision}"
             
                        sh "docker push ${registryIp}/demo/app:${revision}"
                    }
                }
            }
        }
    }
}
