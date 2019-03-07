pipeline{
    agent none
    stages {
        stage('Build'){
            agent {
                docker {
                    image 'maven:3.6.0-jdk-11-slim' 
                    args '-v /root/.m2:/root/.m2'   
                } 
             }
            steps{
                sh "echo 'Im building'"
                sh "maven -v"
            }
        }
        stage('Test'){
            agent any
            steps{
                echo "Here I will make some tests"
            }  
        }
    }
}
