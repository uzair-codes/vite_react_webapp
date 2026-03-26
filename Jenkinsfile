pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'ap-south-1'
    }

    stages {

        stage('Checkout') {
            steps {
                // git branch: 'main', url: ''
                checkout scm
            }
        }
        

        stage('Terraform init') {
            steps {
                dir('v2/server_infra_terraform'){
                    sh 'terraform init'
                }
                
            }
        }

        stage('Plan') {
            steps {
                dir('v2/server_infra_terraform'){
                    sh 'terraform plan -out tfplan' // Generate the plan and save it to a file
                    sh 'terraform show -no-color tfplan > tfplan.txt' // Save the human-readable plan to a text file for review
                }

            }
        }

        stage('Apply / Destroy') {
            steps {

                dir('v2/server_infra_terraform'){
                    script { 
                        if (params.action == 'apply') {
                            if (!params.autoApprove) {
                                // In Jenkins Pipeline (Groovy), "def" is used to define a variable. def variableName = value  
                                // def = dynamically typed variable declaration. def creates a "local variable" inside that script block
                                //  If you want global variable --> plan = readFile 'tfplan.txt' --> no (def) 
                                def plan = readFile 'tfplan.txt'   //Create a variable named "plan", Store contents of "tfplan.txt" in it.
                                input message: "Do you want to apply this plan?",
                                parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                        }

                        sh "terraform ${action} -input=false tfplan" // -input=false -> Disable interactive prompts

                        } else if (params.action == 'destroy') {
                            sh "terraform ${action} --auto-approve"
                        } else {
                            error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                        }
                    }
                }

            }
        }

        stage('Ansible'){
            steps{
                dir('v2/server_config_ansible'){

                    withCredentials([sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                        )]) {
                            sh '''
                            ansible-playbook deploy.yml \
                            --private-key $SSH_KEY
                            '''
                        }
                }
            }
        }

    }

    //  Post Deployment Actions
    post {
        failure {
            echo 'Failure'
            mail to: 'gojosalar@gmail.com',
                subject: "FAILED: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: "Job '${env.JOB_NAME}' - (${env.BUILD_URL}) Failed"
        }
    }
}
