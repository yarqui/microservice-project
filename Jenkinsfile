pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
"""
    }
  }

  environment {
    IMAGE_NAME   = "lesson-9-django-app"
    IMAGE_TAG    = "latest"
  }

  stages {
    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \\
              --context `pwd`/docker/django/neoversity \\
              --dockerfile `pwd`/docker/django/neoversity/Dockerfile \\
              --destination=$ECR_URL:$IMAGE_TAG \\
              --cache=true
          '''
        }
      }
    }
  }
}