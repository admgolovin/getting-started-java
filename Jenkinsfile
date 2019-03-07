pipeline{
    agent any
    stages {
        stage('Build'){
            agent {
                docker {image 'maven:3.6.0-jdk-11-slim' } 
            }
            echo "Build stage is launched" 
            steps{
                sh "echo 'Im building'"
                sh "maven -v"
            }
        }
        stage('Test'){
            echo "Here I will make some tests"
        }
    }
}
