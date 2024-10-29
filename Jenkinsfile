
pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = 'nivisha/my-app:latest'
        GITHUB_REPO = 'https://github.com/Nivisha01/SpringPetClinic.git'
        SONARQUBE_SERVER = 'http://44.196.180.172:9000/'
        SONARQUBE_TOKEN = credentials('sonar-token') 
        PROJECT_NAME = 'project-Ekart'
        SONAR_HOST_URL = "${SONARQUBE_SERVER}"
    }
    stages {
        stage('Checkout Code') {
            steps {
                script {
                    // Checkout code from GitHub repository using credentials
                    git credentialsId: 'GitHub_Credentials', url: "${GITHUB_REPO}", branch: 'main'
                }
            }
        }
        stage('Build with Maven') {
            steps {
                // Build the project and create the artifact
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    // Run SonarQube analysis
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
                        def artifactPath = "target/shopping-cart-0.0.1-SNAPSHOT.war"
                        // Build the Docker image using the WAR file
                        sh "docker build -t ${DOCKER_IMAGE_NAME} -f docker/Dockerfile ."
                        // Push the Docker image to the registry
                        sh "docker push ${DOCKER_IMAGE_NAME}"
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Apply Kubernetes deployment and service configuration
                    sh 'kubectl apply -f k8s-deployment.yaml'
                    sh 'kubectl apply -f k8s-service.yaml'
                }
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
