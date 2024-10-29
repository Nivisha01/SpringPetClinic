pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'JDK17'
    }

    environment {
        DOCKER_IMAGE_NAME = 'spring-petclinic:latest'
        GITHUB_REPO = 'https://github.com/Nivisha01/SpringPetClinic.git'
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    git credentialsId: 'GitHub_Credentials', url: "${GITHUB_REPO}", branch: 'main'
                }
            }
        }

        stage('Clean Workspace') {
            steps {
                deleteDir()  // Clean up the workspace before checkout
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
                sh 'ls -la target/'  // List contents of the target directory to confirm JAR is created
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Use Minikube's Docker daemon to build the image in Minikube's environment
                    sh 'eval $(minikube docker-env)'  
                    sh "docker build -t ${DOCKER_IMAGE_NAME} ."
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                   // Apply the Kubernetes deployment and service
                    sh 'kubectl apply -f k8s-deployment.yaml'
                    sh 'kubectl apply -f k8s-service.yaml'
                }
            }
        }

        stage('Expose Minikube Service') {
            steps {
                script {
                    // Expose the service and get the URL
                    sh 'minikube service spring-petclinic-service --url'
                }
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true  // Archive the generated JAR artifact
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
