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
    IMAGE_NAME      = "final-project-django-app"
    IMAGE_TAG       = "v1.0.${BUILD_NUMBER}"
    COMMIT_EMAIL    = "jenkins@example.com"
    COMMIT_NAME     = "Jenkins CI"
    CHART_VALUES_PATH = "final-project/charts/django-app/values.yaml"
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

              # 1. Clone a fresh copy of the repository into a temp directory
              git clone "https://${GITHUB_USER}:${GITHUB_PAT}@github.com/yarqui/microservice-project.git"
              
              # 2. Enter the cloned repository
              cd microservice-project
              
              # 3. Configure git user for the commit
              git config user.email "${COMMIT_EMAIL}"
              git config user.name "${COMMIT_NAME}"
              git checkout final-project

              # 4. Use our robust sed commands to modify the values.yaml in the fresh clone
              sed -i "/# THIS-LINE-IS-MODIFIED-BY-JENKINS-REPOSITORY/{n; s|repository:.*|repository: \\"${ECR_URL}\\"|;}" "${CHART_VALUES_PATH}"
              sed -i "/# THIS-LINE-IS-MODIFIED-BY-JENKINS-TAG/{n; s|tag:.*|tag: \\"${IMAGE_TAG}\\"|;}" "${CHART_VALUES_PATH}"
              
              # 5. Add, commit, and push the change. No need to check for diffs, as a new build always creates a new tag.
              git add ${CHART_VALUES_PATH}
              git commit -m "ci: Update image to ${IMAGE_TAG} [skip ci]"
              git push origin final-project
            """
          }
        }
      }
    }
  }
}