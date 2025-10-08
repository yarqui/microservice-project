pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-cicd-agent
spec:
  serviceAccountName: jenkins-sa
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.16.0-debug
    imagePullPolicy: Always
    command: [sleep]
    args: [99d]
  - name: git
    image: alpine/git:2.43.0
    imagePullPolicy: Always
    command: [sleep]
    args: [99d]
"""
    }
  }
  environment {
    IMAGE_NAME      = "lesson-9-django-app"
    IMAGE_TAG       = "v1.0.${BUILD_NUMBER}"
    COMMIT_EMAIL    = "jenkins@example.com"
    COMMIT_NAME     = "Jenkins CI"
    CHART_VALUES_PATH = "lesson-9/charts/django-app/values.yaml"
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
    stage('Update Chart and Push to Git') {
      steps {
        container('git') {
          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_PAT')]) {
            sh """
              set -ex

              git config --global user.email "${COMMIT_EMAIL}"
              git config --global user.name "${COMMIT_NAME}"

              git checkout lesson-9

              sed -i "s|repository:.*|repository: \\"${ECR_URL}\\"|" ${CHART_VALUES_PATH}

              awk -v tag="${IMAGE_TAG}" '/tag:/ {gsub(/"[^"]*"/, "\\"" tag "\\"")} 1' ${CHART_VALUES_PATH} > ${CHART_VALUES_PATH}.tmp && mv ${CHART_VALUES_PATH}.tmp ${CHART_VALUES_PATH}
              
              git add ${CHART_VALUES_PATH}
              
              if ! git diff-index --quiet HEAD; then
                git commit -m "ci: Update image tag to ${IMAGE_TAG} [skip ci]"
                git push "https://${GITHUB_USER}:${GITHUB_PAT}@github.com/yarqui/microservice-project.git" HEAD:lesson-9
              else
                echo "No changes to commit."
              fi
            """
          }
        }
      }
    }
  }
}