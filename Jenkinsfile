pipeline {
    agent any

    environment {
        YANDEX_CLOUD_FOLDER_ID = credentials('yc-folder-id') // Укажите правильный ID
        YANDEX_CLOUD_SERVICE_ACCOUNT_KEY = credentials('yc-service-account-key') // Ваш сервисный аккаунт
        TERRAFORM_DIR = './terraform' // Директория с кодом Terraform
        ANSIBLE_DIR = './ansible' // Директория с кодом Ansible
        APP_NAME = 'my-java-app' // Название вашего приложения
        IMAGE_ID = 'fd8b8n7t3u5p7e5q3o5h' // ID образа вашего Docker
        INSTANCE_NAME = 'java-app-instance' // Имя инстанса
    }

    stages {
        stage('Provision Yandex Cloud Instances') {
            steps {
                script {
                    dir("${TERRAFORM_DIR}") {
                        // Инициализация Terraform
                        sh 'terraform init'
                        // Применение конфигурации Terraform
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Build Java Application') {
            steps {
                script {
                    // Сборка вашего Java приложения
                    sh './gradlew build' // Или 'mvn package', если используете Maven
                }
            }
        }

        stage('Deploy Application Using Ansible') {
            steps {
                script {
                    dir("${ANSIBLE_DIR}") {
                        // Используйте ansible-playbook для деплоя вашего приложения
                        sh 'ansible-playbook deploy.yml -i inventory.ini'
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                dir("${TERRAFORM_DIR}") {
                    // Очистка ресурсов после завершения работы
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}