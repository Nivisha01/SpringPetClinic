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
                    // Diagnostic command to verify workspace
                    sh 'pwd && ls -la'

                    // Git checkout with error handling
                    checkout([$class: 'GitSCM',
                              branches: [[name: '*/main']],
                              doGenerateSubmoduleConfigurations: false,
                              extensions: [],
                              userRemoteConfigs: [[credentialsId: 'GitHub_Credentials', url: "${GITHUB_REPO}"]]])
                    
                    // Confirm repository files are present
                    sh 'ls -la'
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
                dir('SpringPetClinic') {
                    sh 'mvn clean package -DskipTests'
                    sh 'ls -la target/'  // List contents of the target directory
                }
            }
        }

        // The remaining stages stay the same
    }

    post {
        success {
            archiveArtifacts artifacts: 'SpringPetClinic/target/*.jar', fingerprint: true
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
