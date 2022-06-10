pipeline {
    agent any
    environment {
        PATH=sh(script:"echo $PATH:/usr/local/bin", returnStdout:true).trim()
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID=sh(script:'export PATH="$PATH:/usr/local/bin" && aws sts get-caller-identity --query Account --output text', returnStdout:true).trim()
        ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        // ECR_REGISTRY = "562636665547.dkr.ecr.us-east-1.amazonaws.com"
        APP_REPO_NAME = "engin_gultekin/todo_app"
    }
    stages {
        stage('Create ECR Repo') {
            steps {
                echo 'Creating ECR Repo for App'
                sh """
                aws ecr create-repository \
                  --repository-name ${APP_REPO_NAME} \
                  --image-scanning-configuration scanOnPush=false \
                  --image-tag-mutability MUTABLE \
                  --region ${AWS_REGION}
                """
            }
        }

        stage('Create Infrastructure for the App') {
            steps {
                echo 'Creating Infrastructure for the worker nodes on AWS Cloud'
                sh "cd /terraform_files/ && terraform init"
                sh "terraform apply -auto-approve"
                sh "cd .."
            }
        }
        stage('Replace Dynamic Values') {
            steps {
                echo 'Find an replace Nodejs and Postgres IP(s) placeholders'
                sh ""
            }
        }

        stage('Test the Infrastructure') {
            
            steps {
                echo "Testing if the worker nodes ready"
                
            }
        }       
        stage('Build Postgres Docker Image') {
            steps {
                echo 'Building Postgres Image'
                sh ''
                // sh ''
                sh 'docker build --force-rm -t "$ECR_REGISTRY/$APP_REPO_NAME:postgres" .'
                sh 'docker image ls'
            }
        }
        stage('Push Postgres Image to ECR Repo') {
            steps {
                echo 'Pushing App Image to ECR Repo'
                sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh ''
                sh 'docker push "$ECR_REGISTRY/$APP_REPO_NAME:postgres"'
            }
        }
        stage('Build React Docker Image') {
            steps {
                echo 'Building React Image'
                sh 'docker build --force-rm -t "$ECR_REGISTRY/$APP_REPO_NAME:react" .'
                sh 'docker image ls'
            }
        }
        stage('Push React Image to ECR Repo') {
            steps {
                echo 'Pushing React Image to ECR Repo'
                sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh ''
                sh 'docker push "$ECR_REGISTRY/$APP_REPO_NAME:react"'
            }
        }    
        stage('Build NodeJs Docker Image') {
            steps {
                echo 'Building NodeJs Image'
                sh 'docker build --force-rm -t "$ECR_REGISTRY/$APP_REPO_NAME:nodejs" .'
                sh 'docker image ls'
            }
        }
        stage('Push NodeJs Image to ECR Repo') {
            steps {
                echo 'Pushing NodeJs Image to ECR Repo'
                sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh ''
                sh 'docker push "$ECR_REGISTRY/$APP_REPO_NAME:nodejs"'
            }
        }    
         
    }
    post {
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
        }
        failure {

            echo 'Delete the Image Repository on ECR due to the Failure'
            sh """
                aws ecr delete-repository \
                  --repository-name ${APP_REPO_NAME} \
                  --region ${AWS_REGION}\
                  --force
                """
            echo 'Deleting Infrastructure due to the Failure'
                sh 'terraform destroy -auto-approve'
        }
    }
}