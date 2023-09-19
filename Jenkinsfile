pipeline {
    agent {
        label 'log4j'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/prabhat-palo/spring_log4j_mysql.git'
            }
        }
        
        stage('Build') {
            steps {
                // Build the Java project with Maven
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Build the Docker image using the Maven build artifacts
                sh 'docker build -t demo_log4j_mysql:v1 target'

                // Push the Docker image to Docker Hub
                // sh 'docker push <image-name>:<tag>'
            }
        }
    }
}
