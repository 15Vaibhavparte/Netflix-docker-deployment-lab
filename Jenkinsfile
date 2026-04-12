pipeline {
    agent any
    
    environment {
        // Your Docker Hub Username
        DOCKERHUB_USER = 'parte15'
        
        // The ID of the credential we created in Jenkins earlier
        DOCKERHUB_CREDS_ID = 'dockerhub-creds'
        
        // This grabs the Jenkins build number (e.g., 1, 2, 14) to use as the tag
        IMAGE_TAG = "${env.BUILD_ID}"
    }
    
    tools {
        maven 'mvn3'
        jdk 'jdk17'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Pulling the latest code for Build #${IMAGE_TAG}..."
                git 'https://github.com/15Vaibhavparte/Netflix-Project.git'
            }
        }
        
        stage('Build Java Artifact') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build & Push Docker Images') {
            steps {
                script {
                    // This securely logs into Docker Hub using your Jenkins credentials
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDS_ID) {
                        
                        echo "Building Frontend Image with Tag: ${IMAGE_TAG}"
                        // Build the image using the Dockerfile in the root directory
                        def frontendImage = docker.build("${DOCKERHUB_USER}/netflix-frontend:${IMAGE_TAG}", "-f Dockerfile .")
                        // Push the uniquely tagged image
                        frontendImage.push()
                        // (Optional) Also push the 'latest' tag so your repo always has the newest version easily accessible
                        frontendImage.push('latest')


                        echo "Building Backend Image with Tag: ${IMAGE_TAG}"
                        // Build the image using the Dockerfile inside the /backend directory
                        def backendImage = docker.build("${DOCKERHUB_USER}/netflix-backend:${IMAGE_TAG}", "-f backend/Dockerfile ./backend")
                        backendImage.push()
                        backendImage.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy Containers') {
            steps {
                script {
                    echo "Deploying newly built images with Tag: ${IMAGE_TAG}..."
                    // We pass the IMAGE_TAG environment variable directly to docker-compose
                    // Notice we removed '--build' because Jenkins already built the images!
                    sh 'IMAGE_TAG=${IMAGE_TAG} docker compose up -d'
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning workspace...'
            cleanWs()
        }
        success {
            echo "Successfully deployed Build #${IMAGE_TAG} to EC2 port 9090!"
        }
    }
}