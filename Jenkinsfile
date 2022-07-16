pipeline {
        agent any
    environment {
        DOCKER_USER = credentials('docker-username')
        DOCKER_PASSWORD = credentials('docker-password') 
    } 
        tools {
                maven "Maven"
        }
    
    stages {
        stage('pullsourceCode'){
            steps{ 
                git branch: 'main', credentialsId: 'git-credentials', url: 'https://github.com/sundaylawal/petclinic-app.git'
            }
        }
        
        stage('BuildCode'){
            steps{ 
                sh 'mvn install -DskipTests=true'
            }
        }
        
        stage('Login to Docker HUB') {
            steps {
                echo '===Login to docker hub ==='
                sh 'docker login --username $DOCKER_USER --password $DOCKER_PASSWORD'
            }
        }
         
        stage('Building Docker Image') { 
            steps {
                echo '=== Creating Docker image==='
                sh 'docker build -t $DOCKER_USER/cloudjerk .' 
            }
        }
        
        stage('TAG Docker Image') {
            steps {
                echo '=== Tagging petclinic Docker Image ==='
                sh 'docker tag $DOCKER_USER/cloudjerk $DOCKER_USER/cloudjerk:latest'
            }
        }
        stage('Push Docker Image to docker hub') {
            steps {
                echo '=== Pushing Petclinic Docker Image ==='
                sh 'docker push $DOCKER_USER/cloudjerk:latest'
            }
        }
        
        stage ('K8S Deploy') {
                steps {
                kubernetesDeploy(
                    configs: 'deployfile.yml',
                    kubeconfigId: 'kubernetes',
                    enableConfigSubstitution: true
                    ) 
                }
        }
  }
}
