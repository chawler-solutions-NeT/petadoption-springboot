pipeline {
    agent any
    tools {
        maven 'maven'
    }

    environment {
        // This can be nexus3 or nexus2
        NEXUS_VERSION = "nexus3"
        // This can be http or https
        NEXUS_PROTOCOL = "http"
        // Where your Nexus is running
        NEXUS_URL = "3.221.155.101:8081"
        // Repository where we will upload the artifact
        NEXUS_REPOSITORY = "petadoption"
        // Jenkins credential id to authenticate to Nexus OSS
        NEXUS_CREDENTIAL_ID = "nexus"

    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/chawler-solutions-NeT/petadoption-springboot.git'
            }
        }
    
        stage('Compile and Build') {
            steps {
                sh "mvn clean install -Dmaven.test.skip=true -Dcheckstyle.skip"
            }
        }
        
        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv(installationName:'sonarqube', credentialsId: 'sonarqube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=csnet -X'
                }
            }
        }

        stage("quality gate"){
            steps {
                sleep(10)
                script {
                  waitForQualityGate abortPipeline: false, credentialsId: 'sonarqube' 
                }
           }
        }
        
        stage("publish to nexus") {
            steps {
                script {
                    // Read POM xml file using 'readMavenPom' step , this step 'readMavenPom' is included in: https://plugins.jenkins.io/pipeline-utility-steps
                    pom = readMavenPom file: "pom.xml";
                    // Find built artifact under target folder
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    // Print some info from the artifact found
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    // Extract the path from the File found
                    artifactPath = filesByGlob[0].path;
                    // Assign to a boolean response verifying If the artifact name exists
                    artifactExists = fileExists artifactPath;

                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";

                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                // Artifact generated such as .jar, .ear and .war files.
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging]
                            ]
                        );

                    } else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }
        }

    
        stage('Tomcat Deploy') {
            steps {
                deploy adapters: [tomcat9(credentialsId: 'tomcat', path: '', url: 'http://3.235.127.123:8085/')], contextPath: null, onFailure: false, war: '**/*.war'
            }
        }
        
        stage('Start Java application') {
            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: 'tomcat', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'screen -dmS myapp sudo java -jar /opt/tomcat9/webapps/spring-petclinic-2.4.2.war', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
        }
        
        //stage('OWASP Dependency Check') {
         //   steps {
          //      script {
         //           dependencyCheck additionalArguments: "--scan target/", odcInstallation: 'owasp'
          //          dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
          //      }
         ///   }
       //}
        
    }    
    
}