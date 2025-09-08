pipeline {
    agent any 
    stages {
        stage('git version') {
            steps {
                sh 'git version'
            }
        }
        stage('terraform version') {
            steps {
                sh 'terraform version'
            }
        }
        stage('docker version') {
            steps {
                sh 'docker version'
            }
        }
        stage('ansible version') {
            steps {
                sh 'ansible --version'
            }
        }
        stage('kubectl version') {
            steps {
                sh 'kubectl version'
            }
        }
    }
}