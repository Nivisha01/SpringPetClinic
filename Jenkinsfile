pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'JDK17'
    }

    environment {
        DOCKER_IMAGE_NAME = 'nivisha/my-app:latest'
        GITHUB_REPO = 'https://github.com/Nivisha01/SpringPetClinic.git'
        SONARQUBE_SERVER = 'http://44.196.180.172:9000/'
        SONARQUBE_TOKEN = credentials('sonar-token')
        PROJECT_NAME = 'project-SpringPetClinic'
        SONAR_HOST_URL = "${SONARQUBE_SERVER}"
        DOCKER_CREDENTIALS_ID = 'DockerHub_Cred'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                deleteDir()  // Clean up the workspace before checkout
            }
        }
        stage('Checkout Code') {
            steps {
                script {
                    git credentialsId: 'GitHub_Credentials', url: "${GITHUB_REPO}", branch: 'main'
                }
            }
        }
        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        mvn sonar:sonar \
                        -Dmaven.test.skip=true \
                        -Dsonar.projectKey=${PROJECT_NAME} \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.login=${SONARQUBE_TOKEN}
                    """
                }
            }
        }
        stage('Docker Build and Push') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE_NAME} ."

                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                        sh "docker push ${DOCKER_IMAGE_NAME}"
                    }
                }
            }
        }
        stage('Debug Minikube Environment') {
            steps {
                script {
                    sh 'minikube status'
                    sh 'minikube ip'
                    sh 'kubectl config current-context'
                }
            }
        }
        stage('Prepare for Deployment') {
            steps {
                script {
                    sh 'export KUBECONFIG=$HOME/.kube/config'
                    sh 'kubectl config use-context minikube || exit 1'
                    sh 'ls -la ${WORKSPACE}'
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh 'kubectl apply -f ${WORKSPACE}/k8s-deployment.yaml --validate=false'
                    sh 'kubectl apply -f ${WORKSPACE}/k8s-service.yaml --validate=false'
                    sh 'kubectl get deployments'
                    sh 'kubectl get pods'
                    sh 'kubectl get services'
                }
            }
        }
    }
    post {
        success {
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
        always {
            echo 'Cleaning up...'
        }
    }
}
