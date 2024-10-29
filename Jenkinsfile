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
        stage('Docker Build and Push') {
            steps {
                script {
                    // Set up Minikube Docker environment
                    sh 'eval $(minikube -p minikube docker-env) || exit 1'
        
                    // Build the Docker image
                    sh "docker build -t ${DOCKER_IMAGE_NAME} ."
            
                    // Authenticate and push the Docker image to DockerHub
                    docker.withRegistry('https://index.docker.io/v1/', 'DockerHub_Cred') {
                        sh "docker push ${DOCKER_IMAGE_NAME}"
                    }
                }
            }
        }
        stage('Debug Minikube Environment') {
            steps {
                script {
                    // Print Minikube status and environment for troubleshooting
                    sh 'minikube status'
                    sh 'minikube ip'
                    sh 'kubectl config current-context'
                    sh 'docker info'
                }
            }
        }
        stage('Prepare for Deployment') {
            steps {
                script {
                    // Set KUBECONFIG environment variable for Jenkins
                    sh 'export KUBECONFIG=$HOME/.kube/config'
                    // Set Minikube context explicitly
                    sh 'kubectl config use-context minikube || exit 1'
                    // Verify that the deployment files are present
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
                    // Apply the deployment and service YAML files to Kubernetes
                    sh 'kubectl apply -f ${WORKSPACE}/k8s-deployment.yaml --validate=false'
                    sh 'kubectl apply -f ${WORKSPACE}/k8s-service.yaml --validate=false'
                    // Display the status of deployments, pods, and services for debugging
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
