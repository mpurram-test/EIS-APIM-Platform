/* groovylint-disable */

// Constants to eliminate duplicate string literals
@Field static final List SUPPORTED_ENVS = ['stage', PROD_ENV]
@Field static final String PROD_ENV = 'prod'
@Field static final String ARM_SUBSCRIPTION_ID = 'ARM_SUBSCRIPTION_ID'
@Field static final String ARM_CLIENT_ID = 'ARM_CLIENT_ID'
@Field static final String ARM_CLIENT_SECRET = 'ARM_CLIENT_SECRET'
@Field static final String ARM_TENANT_ID = 'ARM_TENANT_ID'
@Field static final String RESOURCE_GROUP_NAME_CRED = 'RESOURCE_GROUP_NAME_CRED'
@Field static final String APIM_NAME_CRED = 'APIM_NAME_CRED'
@Field static final String APIM_APP_ID_SECRET = 'APIM_APP_ID_SECRET'

pipeline {
  agent { label 'dev' }

  parameters {
    choice(name: 'ENV', choices: SUPPORTED_ENVS, description: 'Target environment')
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

    stage('Resolve ENV & Credentials') {
      steps {
        script {
          validateEnvironment()
          configureCredentials()
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
        withCredentials([
          string(credentialsId: env.CRED_AZURE_SUBSCRIPTION_ID, variable: ARM_SUBSCRIPTION_ID),
          string(credentialsId: env.CRED_AZURE_CLIENT_ID, variable: ARM_CLIENT_ID),
          string(credentialsId: env.CRED_AZURE_CLIENT_SECRET, variable: ARM_CLIENT_SECRET),
          string(credentialsId: env.CRED_AZURE_TENANT_ID, variable: ARM_TENANT_ID)
        ]) {
          sh """
            set -e
            echo "[Init] Using TF_DIR=${TF_DIR} BACKEND_FILE=${BACKEND_FILE}"
            terraform -chdir="${TF_DIR}" init -backend-config="${BACKEND_FILE}" -lock-timeout=5m -input=false -no-color

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
    }

    stage('Terraform Plan') {
      steps {
        withCredentials([
          string(credentialsId: env.CRED_RG_ID, variable: RESOURCE_GROUP_NAME_CRED),
          string(credentialsId: env.CRED_APIM_NAME_ID, variable: APIM_NAME_CRED),
          string(credentialsId: env.CRED_APP_ID, variable: APIM_APP_ID_SECRET),
          string(credentialsId: env.CRED_AZURE_SUBSCRIPTION_ID, variable: ARM_SUBSCRIPTION_ID),
          string(credentialsId: env.CRED_AZURE_CLIENT_ID, variable: ARM_CLIENT_ID),
          string(credentialsId: env.CRED_AZURE_CLIENT_SECRET, variable: ARM_CLIENT_SECRET),
          string(credentialsId: env.CRED_AZURE_TENANT_ID, variable: ARM_TENANT_ID)
        ]) {
          sh """
            #!/usr/bin/env bash
            set -e
            export TF_VAR_apim_app_id="${APIM_APP_ID_SECRET}"
            export TF_VAR_azure_tenant_id="${ARM_TENANT_ID}"
            set +e
            terraform -chdir="${TF_DIR}" plan -detailed-exitcode -lock-timeout=5m -input=false -no-color \
              -var="resource_group_name=${RESOURCE_GROUP_NAME_CRED}" \
              -var="api_management_name=${APIM_NAME_CRED}" \
              -out=tfplan.out
            PLAN_STATUS=\$?
            set -e

            if [ "${PLAN_STATUS}" -eq 1 ]; then
              echo "ERROR: Terraform plan failed"
              exit 1
            fi

            if [ "${PLAN_STATUS}" -eq 0 ]; then
              echo "[Plan] No infrastructure changes detected"
              rm -f "${TF_DIR}/has_changes.flag"
              exit 0
            fi

            touch "${TF_DIR}/has_changes.flag"

            PLAN_FILE_PATH="${TF_DIR}/tfplan.out"
            if [ ! -f "\${PLAN_FILE_PATH}" ]; then
              echo "ERROR: Plan command finished but plan file missing at \${PLAN_FILE_PATH}"
              exit 1
            fi
            echo "[Plan] Plan file created at \${PLAN_FILE_PATH}"
          """
        }
      }
      post {
        always {
          archiveArtifacts artifacts: "${TF_DIR}/tfplan.out", fingerprint: true, allowEmptyArchive: false
        }
      }
    }

    stage('Production Approval') {
      when {
        expression { env.TF_ENV == PROD_ENV }
      }
      steps {
        input message: "Approve Terraform apply to ${env.TF_ENV}?", ok: 'Deploy'
      }
    }

    stage('Terraform Apply') {
      steps {
        withCredentials([
          string(credentialsId: env.CRED_RG_ID, variable: RESOURCE_GROUP_NAME_CRED),
          string(credentialsId: env.CRED_APIM_NAME_ID, variable: APIM_NAME_CRED),
          string(credentialsId: env.CRED_APP_ID, variable: APIM_APP_ID_SECRET),
          string(credentialsId: env.CRED_AZURE_SUBSCRIPTION_ID, variable: ARM_SUBSCRIPTION_ID),
          string(credentialsId: env.CRED_AZURE_CLIENT_ID, variable: ARM_CLIENT_ID),
          string(credentialsId: env.CRED_AZURE_CLIENT_SECRET, variable: ARM_CLIENT_SECRET),
          string(credentialsId: env.CRED_AZURE_TENANT_ID, variable: ARM_TENANT_ID)
        ]) {
          sh """
            #!/usr/bin/env bash
            set -e

            PLAN_FILE="tfplan.out"
            PLAN_FILE_PATH="${TF_DIR}/\${PLAN_FILE}"
            export TF_VAR_apim_app_id="${APIM_APP_ID_SECRET}"
            export TF_VAR_azure_tenant_id="${ARM_TENANT_ID}"
            echo "[Apply] Workspace: \$(pwd)"
            echo "[Apply] TF_DIR=${TF_DIR}"

            if [ ! -f "${TF_DIR}/has_changes.flag" ]; then
              echo "[Apply] No changes detected in plan stage; skipping apply"
              exit 0
            fi

            echo "[Apply] Expecting plan at \${PLAN_FILE_PATH}"
            if [ ! -f "\${PLAN_FILE_PATH}" ]; then
              echo "ERROR: Plan file not found at \${PLAN_FILE_PATH}"
              ls -la "${TF_DIR}" || true
              exit 1
            fi

            echo "[Apply] Applying plan..."
            if ! terraform -chdir="${TF_DIR}" apply -lock-timeout=5m \
              -input=false -no-color -auto-approve "\${PLAN_FILE}"; then
              echo "ERROR: Apply failed. Automatic targeted rollback is disabled by policy."
              echo "Please perform controlled manual recovery using approved runbook."
              exit 1
            fi

            rm -f "${TF_DIR}/has_changes.flag"
            echo "[Apply] Deployment successful"
          """
        }
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

// Helper methods to reduce nesting and improve readability
void validateEnvironment() {
  env.TF_ENV = params.ENV?.trim()
  if (!env.TF_ENV) {
    error 'ENV build parameter is required (for example: stage or prod)'
  }
  if (!SUPPORTED_ENVS.contains(env.TF_ENV)) {
    error "Unsupported ENV=${env.TF_ENV}. Expected one of: ${SUPPORTED_ENVS.join(', ')}"
  }
}

void configureCredentials() {
  String credPrefix = env.TF_ENV
  env.with {
    TF_DIR = "terraform/envs/${env.TF_ENV}"
    BACKEND_FILE = 'backend.tfvars'
    CRED_RG_ID = "${credPrefix}-apim-rg-name"
    CRED_APIM_NAME_ID = "${credPrefix}-apim-apim-name"
    CRED_APP_ID = "${credPrefix}-apim-app-id"
    CRED_AZURE_SUBSCRIPTION_ID = "${credPrefix}-apim-azure-subscription-id"
    CRED_AZURE_CLIENT_ID = "${credPrefix}-apim-azure-client"
    CRED_AZURE_CLIENT_SECRET = "${credPrefix}-apim-azure-secret"
    CRED_AZURE_TENANT_ID = "${credPrefix}-apim-azure-tenant"
  }
  echo "Computed ENV=${env.TF_ENV} TF_DIR=${env.TF_DIR} BACKEND_FILE=${env.BACKEND_FILE}"
}
