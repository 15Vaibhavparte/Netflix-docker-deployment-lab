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
                echo "Compiling the code and generating the .war file..."
                sh 'mvn clean package -DskipTests'
            }
        }

        // --- PARALLEL EXECUTION BLOCK ---
        stage('Build & Push Docker Images') {
            // failFast true means if frontend fails, it immediately stops backend (saving EC2 resources)
            failFast true 
            
            parallel {
                stage('Frontend Image') {
                    steps {
                        script {
                            echo "Building Frontend Image with Tag: ${IMAGE_TAG}"
                            docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDS_ID) {
                                def frontendImage = docker.build("${DOCKERHUB_USER}/netflix-frontend:${IMAGE_TAG}", "-f Dockerfile .")
                                frontendImage.push()
                                frontendImage.push('latest')
                            }
                        }
                    }
                }
                
                stage('Backend Image') {
                    steps {
                        script {
                            echo "Building Backend Image with Tag: ${IMAGE_TAG}"
                            docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDS_ID) {
                                def backendImage = docker.build("${DOCKERHUB_USER}/netflix-backend:${IMAGE_TAG}", "-f backend/Dockerfile ./backend")
                                backendImage.push()
                                backendImage.push('latest')
                            }
                        }
                    }
                }
            }
        }
        // --------------------------------
        
        stage('Deploy Containers') {
            steps {
                script {
                    echo "Deploying newly built images with Tag: ${IMAGE_TAG}..."
                    // We pass the IMAGE_TAG environment variable directly to docker-compose
                    sh 'IMAGE_TAG=${IMAGE_TAG} docker compose up -d'
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning workspace...'
            cleanWs()
            
            // Optional but highly recommended for EC2: 
            // clear out dangling images so your disk doesn't fill up
            sh 'docker system prune -f'
        }
        success {
            echo "Successfully deployed Build #${IMAGE_TAG} to EC2 port 9090!"
        }
    }
}