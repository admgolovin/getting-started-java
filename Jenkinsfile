def branch
def revision
def registryIp

pipeline {

    agent {
        kubernetes {
            label 'build-service-pod-java'
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
  - name: helm-cli
    image: linkyard/docker-helm
    command: ["cat"]
    tty: true
    resources:
      limits:
        ephemeral-storage: "2Gi"
      requests:
        ephemeral-storage: "100Mi"
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


    stages ('Tests') {
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
                        sh "echo registryIp=818353068367.dkr.ecr.eu-central-1.amazonaws.com/tony > build.properties"
                        sh "echo buildNumber=${revision} >> build.properties"
                        }   
                    }
                }
            }
        }
        // stage ('clean workspace'){
        //     steps{
        //         cleanWs()
        //     }
        // }
    }
    post {
        always {
            archiveArtifacts artifacts: 'build.properties'
          }
        }
}
