/* groovylint-disable CompileStatic */

pipeline {
  agent { label 'dev' }

  parameters {
    choice(name: 'ENV', choices: ['preprod', 'prod'], description: 'Target environment')
  }

  options {
    timestamps()
    disableConcurrentBuilds()
    timeout(time: 60, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  environment {
    TF_INPUT         = 'false'
    TF_IN_AUTOMATION = 'true'
    RESOURCE_GROUP_NAME_CRED = credentials('stage-apim-rg-name')
    APIM_NAME_CRED           = credentials('stage-apim-apim-name')
    ARM_SUBSCRIPTION_ID      = credentials('stage-apim-azure-subscription-id')
    ARM_CLIENT_ID            = credentials('stage-apim-azure-client')
    ARM_CLIENT_SECRET        = credentials('stage-apim-azure-secret')
    ARM_TENANT_ID            = credentials('stage-apim-azure-tenant')
  }

  stages {
    stage('Preflight: Tooling') {
      steps {
        sh '''
          #!/usr/bin/env bash
          set -e
          echo "[Preflight] Checking required tools..."

          if ! command -v terraform >/dev/null 2>&1; then
            echo "ERROR: Terraform not installed."
            exit 1
          fi

          echo "[Preflight] OK"
        '''
      }
    }

    stage('Resolve ENV & TF_DIR') {
      steps {
        script {
          env.TF_ENV = params.ENV?.trim() ?: (env.BRANCH_NAME == 'main' ? 'prod' : 'preprod')
          env.TF_DIR = "terraform/envs/${env.TF_ENV}"
          echo "Computed ENV=${env.TF_ENV}  TF_DIR=${env.TF_DIR}"
        }
      }
    }

    stage('Checkout') {
      steps {
        checkout scm
        sh '''
          #!/usr/bin/env bash
          set -e
          echo "Repo root:" && ls -la
        '''
      }
    }
    stage('Terraform Init/Validate') {
      steps {
        sh """
          set -e

          echo "[Init] Using TF_DIR=${TF_DIR}"
          terraform -chdir="${TF_DIR}" init -backend-config=backend.tfvars -input=false -no-color

          set +e
          FMT_OUTPUT=\$(terraform -chdir="${TF_DIR}" fmt -check -diff -recursive -no-color 2>&1)
          FMT_STATUS=\$?
          set -e
          if [ "\${FMT_STATUS}" -ne 0 ]; then
            echo "[Terraform] fmt issues detected:"
            echo "\${FMT_OUTPUT}"
            exit \${FMT_STATUS}
          fi

          terraform -chdir="${TF_DIR}" validate -no-color
        """
      }
    }

    stage('Terraform Plan') {
      steps {
        sh """
          #!/usr/bin/env bash
          set -e

          terraform -chdir="${TF_DIR}" plan -input=false -no-color \
            -var="resource_group_name=${RESOURCE_GROUP_NAME_CRED}" \
            -var="api_management_name=${APIM_NAME_CRED}" \
            -out=tfplan.out
        """
      }
      post {
        always {
          archiveArtifacts artifacts: "${TF_DIR}/tfplan.out", fingerprint: true, allowEmptyArchive: false
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        sh """
          #!/usr/bin/env bash
          set -e

          PLAN_FILE="${TF_DIR}/tfplan.out"
          if [ ! -f "\${PLAN_FILE}" ]; then
            echo "ERROR: Plan file not found at \${PLAN_FILE}"
            exit 1
          fi

          # Capture state before apply
          STATE_BEFORE="${TF_DIR}/state_before.txt"
          terraform -chdir="${TF_DIR}" state list > "\${STATE_BEFORE}" 2>/dev/null || true
          echo "[Apply] State snapshot saved: \$(wc -l < \${STATE_BEFORE}) resources"

          # Attempt apply
          echo "[Apply] Applying plan..."
          if ! terraform -chdir="${TF_DIR}" apply -input=false -no-color -auto-approve "\${PLAN_FILE}"; then
            echo "[Rollback] Apply failed. Rolling back newly created resources..."

            # Capture state after failed apply
            STATE_AFTER="${TF_DIR}/state_after.txt"
            terraform -chdir="${TF_DIR}" state list > "\${STATE_AFTER}" 2>/dev/null || true

            # Find resources that were created in this run (exist in AFTER but not in BEFORE)
            # avoid bash process substitution to keep Groovy lint happy
            NEW_RESOURCES=\$(grep -Fxv -f "\${STATE_BEFORE}" "\${STATE_AFTER}" || true)

            if [ -n "\${NEW_RESOURCES}" ]; then
              echo "[Rollback] Found \$(echo \"\${NEW_RESOURCES}\" | wc -l) newly created resources. Destroying..."
              echo "\${NEW_RESOURCES}" | while IFS= read -r resource; do
                echo "[Rollback] Destroying: \${resource}"
                terraform -chdir="${TF_DIR}" destroy -target="\${resource}" -auto-approve -no-color
              done
              echo "[Rollback] Cleanup complete"
            else
              echo "[Rollback] No newly created resources found to destroy"
            fi

            # Clean up state files
            rm -f "\${STATE_BEFORE}" "\${STATE_AFTER}"
            exit 1
          fi

          # Clean up state files on success
          rm -f "${TF_DIR}/state_before.txt" "${TF_DIR}/state_after.txt"
          echo "[Apply] Deployment successful"
        """
      }
    }
  }

  post {
    success {
      echo "Build succeeded. ${BUILD_URL}"
    }
    failure {
      echo "Build failed: ${BUILD_URL}"
    }
    always {
      sh '''
        find . -name "tfplan.out" -delete
        echo "[Cleanup] Removed tfplan files"
      '''
    }
  }
}
