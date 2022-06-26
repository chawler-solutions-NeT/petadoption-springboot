pipeline{
    environment{
        registry = "sundaylawal/cloudjerk"
        registryCredential = 'docker-creds'
        dockerImage = ''
    }
    agent any
    tools {
    maven 'Maven'
  }
    stages{
        stage('Pull Source Code from GitHub') {
            steps {
                git branch: 'main', credentialsId: 'git', url: 'https://github.com/sundaylawal/petclinic-app.git'
            }
        }
        
        stage('Build Code') {
            steps {
               sh 'mvn package -Dmaven.test.skip'
            }
        }
           stage('Building Docker Image') {
                steps {
                    script{
                        dockerImage = docker.build registry + ":$BUILD_NUMBER"
                    }
                }
           
            }
             stage('Push to DockerHub') {
                steps {
                    script {
                        docker.withRegistry( '', registryCredential ){
                            dockerImage.push()
                        }
                    }
                }
           
            }
          
            
    }
}
