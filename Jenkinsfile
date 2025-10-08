// pipeline {
//   agent {
//     kubernetes {
//       yaml """
// apiVersion: v1
// kind: Pod
// metadata:
//   labels:
//     some-label: jenkins-kaniko
// spec:
//   serviceAccountName: jenkins-sa
//   containers:
//     - name: kaniko
//       image: gcr.io/kaniko-project/executor:v1.16.0-debug
//       imagePullPolicy: Always
//       command:
//         - sleep
//       args:
//         - 99d

//     - name: git
//       image: alpine/git
//       command:
//         - sleep
//       args:
//         - 99d 
// """
//     }
//   }

//   environment {
//     IMAGE_NAME   = "lesson-9-django-app"
//     // IMAGE_TAG    = "latest"
//     IMAGE_TAG    = "v1.0.${BUILD_NUMBER}" # TODO: replaced latest
    
//     COMMIT_EMAIL = "jenkins@localhost"
//     COMMIT_NAME  = "jenkins"
//   }

//   stages {
//     stage('Build & Push Docker Image') {
//       steps {
//         container('kaniko') {
//           sh '''
//             /kaniko/executor \\
//               --context `pwd`/docker/django/neoversity \\
//               --dockerfile `pwd`/docker/django/neoversity/Dockerfile \\
//               --destination=$ECR_URL:$IMAGE_TAG \\
//               --cache=true
//           '''
//         }
//       }
//     }

//     stage('Update Chart Tag in Git') {
//       steps {
//         container('git') {
//           withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_PAT')]) {
//             sh '''
//               git clone https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_USER}/microservice-project.git
//               cd lesson-9/charts/django-app

//               git config user.email "$COMMIT_EMAIL"
//               git config user.name "$COMMIT_NAME"

//               sed -i "s|    repository: .*|    repository: \\"${ECR_URL}\\"|" lesson-9/charts/django-app/values.yaml
//               sed -i "s|tag: .*|tag: \\"$IMAGE_TAG\\"|" lesson-9/charts/django-app/values.yaml


//               git add lesson-9/charts/django-app/values.yaml
//               git commit -m "Update image tag to $IMAGE_TAG"
//               git push origin main
//             '''
//           }
//         }
//       }
//     }
//   }
// }
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
    IMAGE_NAME   = "lesson-9-django-app"
    IMAGE_TAG    = "v1.0.${BUILD_NUMBER}"
    COMMIT_EMAIL = "jenkins@example.com"
    COMMIT_NAME  = "Jenkins CI"
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
              git config --global user.email "${COMMIT_EMAIL}"
              git config --global user.name "${COMMIT_NAME}"

              awk -v tag="${IMAGE_TAG}" '/^  tag:/ {$2 = "\"" tag "\""} 1' ${CHART_VALUES_PATH} > ${CHART_VALUES_PATH}.tmp && mv ${CHART_VALUES_PATH}.tmp ${CHART_VALUES_PATH}

              git add ${CHART_VALUES_PATH}
              git commit -m "ci: Update image tag to ${IMAGE_TAG}"

              git push "https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_USER}/microservice-project.git" HEAD:main
            """
          }
        }
      }
    }
  }
}