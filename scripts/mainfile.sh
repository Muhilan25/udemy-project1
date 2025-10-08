pipeline {
    agent any

    environment {
        cred = credentials('aws-key')
    }

    options {
        buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '30', numToKeepStr: '5'))
        timeout(time: 30, unit: 'MINUTES')
    }

    tools {
        maven 'Maven'
    }

    stages {
        stage('checkout') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/main']],
                    extensions: [],
                    userRemoteConfigs: [[url: 'https://github.com/Muhilan25/udemy-project1.git']]
                )
            }
        }

        stage('sonar test') {
            steps {
                script {
                    def mvn = tool 'Maven'
                    withSonarQubeEnv('sonarqube-server') {
                        sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=udemyproject -Dsonar.projectName='udemyproject'"
                    }
                }
            }
        }

        stage('maven build') {
            steps {
                sh 'mvn package'
            }
        }

        stage('nexus test') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: '13.201.120.114:8081/',
                    groupId: 'addressbook',
                    version: '2.0-SNAPSHOT',
                    repository: 'maven-snapshots',
                    credentialsId: 'nexus',
                    artifacts: [
                        [artifactId: 'udemyproject',
                        classifier: '',
                        file: 'target/addressbook-2.0.war',
                        type: 'war']
                    ]
                )
            }
        }

        stage('docker build') {
            steps {
                sh "docker build -t project1 ."
            }
        }

        stage('docker push') {
            steps {
                sh "aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 479984738014.dkr.ecr.ap-south-1.amazonaws.com"
                sh "docker tag project1:latest 479984738014.dkr.ecr.ap-south-1.amazonaws.com/project1:latest"
                sh "docker push 479984738014.dkr.ecr.ap-south-1.amazonaws.com/project1:latest"
            }
        }

        stage('kubectl deployment') {
            steps {
                sh "aws eks update-kubeconfig --name learnwithmuhilan"
                sh "kubectl apply -f Application.yaml"
            }
        }
    }

    post {
        always {
            echo "job completed"
        }
        success {
            echo "passed"
        }
        failure {
            echo "failed"
        }
    }
}
