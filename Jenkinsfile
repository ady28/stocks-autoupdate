pipeline { 
    agent {
        node {
            label 'master'
        }
    }
    environment { 
        DOCKERHUB_USER = 'ady28'
        IMAGE_NAME = 'stocks-autoupdate'
        IMAGE_VERSION = ''
    }
    stages {
        stage('Static code analysis') {
            steps {
                sh 'pwsh -command "& {Invoke-ScriptAnalyzer -Path functions.ps1 -ExcludeRule PSUseShouldProcessForStateChangingFunctions -EnableExit -ReportSummary}"'
                sh 'pwsh -command "& {Invoke-ScriptAnalyzer -Path main.ps1 -ExcludeRule PSUseShouldProcessForStateChangingFunctions -EnableExit -ReportSummary}"'
            }
        }
        stage('Dockerfile check') {
            steps {
                script {
                    sh "hadolint Dockerfile --info DL3008 -t warning -f json | tee -a dockerfile_lint.json"
                }
            }
        }
        stage('Build') { 
            steps { 
                echo "Running build stage for ${env.IMAGE_NAME}"
                script {
                    IMAGE_VERSION = readFile('VERSION').trim()
                    image = docker.build("${env.DOCKERHUB_USER}/${env.IMAGE_NAME}:${IMAGE_VERSION}")
                    docker.withRegistry("https://registry.hub.docker.com", 'dockerhub-pub') {
                        image.push()
                    }
                }
                sh "docker sbom ${env.DOCKERHUB_USER}/${env.IMAGE_NAME}:${IMAGE_VERSION} --format syft-json -o sbom.json"
            }
        }
        stage('Tag Test Image'){
            steps {
                echo "Push image for testing"
                script {
                    docker.withRegistry("https://registry.hub.docker.com", 'dockerhub-pub') {
                        image.push("test")
                    }
                }
            }
        }
        stage('Deploy Test Infrastructure') {
            steps {
                build job: 'stocks-app-test-deploy'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'sbom.json, dockerfile_lint.json', fingerprint: true
        }
    }
}