pipeline {
    agent any
    environment {
        cred = credentials('aws-key')
        # befor we have created aws credential and added in tools in jenkins 
    }
    stages {
        stage('checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Muhilan25/udemy-project1.git']])  
                # /its is generated using pipeline syntax by giving github repo  
            }
        }
        stage('terrafrom init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('terraform apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
    }
}