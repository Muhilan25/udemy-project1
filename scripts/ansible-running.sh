pipeline {
    agent any 
    environment {
        privatekey = credentials('ansiblekey')
    }
    stages {
        stage('checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Muhilan25/udemy-project1.git']])  
            }
        }
        stage('ansible test') {
            steps {
                sh "ansible all -i inventory -m ping --private-key ${privatekey}"
                sh "ansible-playbook -i inventory --private-key ${privatekey} playbook.yaml"
            }
        }
    }
}