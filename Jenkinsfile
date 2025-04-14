pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker-registry'
        APP_NAME = 'tb-platform'
        DOCKER_CREDS = credentials('docker-credentials')
        KUBE_CONFIG = credentials('kubernetes-config')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run Tests') {
            steps {
                sh 'pip install -r requirements.txt'
                sh 'python tests/test.py'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def dockerImage = docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}")
                    docker.withRegistry('https://${DOCKER_REGISTRY}', 'docker-credentials') {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Environment') {
            steps {
                script {
                    def branch = env.BRANCH_NAME
                    def environment = ''
                    switch(branch) {
                        case 'develop':
                            environment = 'dev'
                            break
                        case 'qa':
                            environment = 'qa'
                            break
                        case 'preprod':
                            environment = 'preprod'
                            break
                        case 'main':
                            environment = 'prod'
                            break
                        default:
                            error "Branch ${branch} not configured for deployment"
                    }
                    
                    withKubeConfig([credentialsId: 'kubernetes-config']) {
                        sh """
                            kubectl set image deployment/${APP_NAME} ${APP_NAME}=${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER} -n tb-platform-${environment}
                            kubectl rollout status deployment/${APP_NAME} -n tb-platform-${environment}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}