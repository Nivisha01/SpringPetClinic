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
        PROJECT_NAME = 'project-SpringPetClinic'  // Updated to reflect the correct project name
        SONAR_HOST_URL = "${SONARQUBE_SERVER}"
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
                sh 'ls -la target/'  // List contents of the target directory
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
        stage('Docker Build') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'DockerHub_Cred') {
                        sh "docker build -t ${DOCKER_IMAGE_NAME} ."
                        sh "docker push ${DOCKER_IMAGE_NAME}"
                    }
                }
            }
        }
        stage('Prepare for Deployment') {
            steps {
                script {
                    // Set Minikube context explicitly
                    sh 'kubectl config use-context minikube'
                    // Verify that the deployment file is present
                    sh 'ls -la ${WORKSPACE}'
                    // Display current Kubernetes context and cluster info
                    sh 'kubectl config current-context'
                    sh 'kubectl cluster-info'
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Applying the deployment and service YAML to Kubernetes
                    sh 'kubectl apply -f ${WORKSPACE}/k8s-deployment.yaml --validate=false'
                    sh 'kubectl apply -f ${WORKSPACE}/k8s-service.yaml --validate=false'
                    // Display status of deployments, pods, and services for debugging
                    sh 'kubectl get deployments'
                    sh 'kubectl get pods'
                    sh 'kubectl get services'
                }
            }
        }
    }
    post {
        success {
            // Archive the artifact file
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true  // Change to .war if necessary
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
