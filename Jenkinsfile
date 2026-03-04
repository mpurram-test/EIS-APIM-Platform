pipeline {
  agent { label 'dev' }

  parameters {
    choice(name: 'ENV', choices: ['preprod', 'prod'], description: 'Target environment')
  }

  options {
    timestamps()
    disableConcurrentBuilds()
    timeout(time: 60, unit: 'MINUTES')
  }

  environment {
    TF_INPUT         = 'false'
    TF_IN_AUTOMATION = 'true'
    RESOURCE_GROUP_NAME_CRED = credentials('stage-apim-rg-name')
    APIM_NAME_CRED           = credentials('stage-apim-apim-name')
  }

  stages {
    stage('Preflight: Tooling') {
      steps {
        sh '''
          #!/usr/bin/env bash
          set -e
          echo "[Preflight] Checking required tools..."

          if ! command -v docker >/dev/null 2>&1 && ! command -v node >/dev/null 2>&1; then
            echo "ERROR: Need Docker or Node to run Redocly CLI."
            exit 1
          fi

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
          env.TF_DIR = "terraform/envs/${env.TF_ENV}"   // or "apim/terraform/${env.TF_ENV}" if that’s your path
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
          echo ""
          echo "API dir:" && ls -la api || true
        '''
      }
    }

    stage('Terraform Init/Validate') {
      steps {
        sh '''
          #!/usr/bin/env bash
          set -e

          echo "[Terraform] Init in: ${TF_DIR}"
          terraform -chdir="${TF_DIR}" init -input=false -no-color

          set +e
          FMT_OUTPUT=$(terraform -chdir="${TF_DIR}" fmt -check -diff -recursive -no-color 2>&1)
          FMT_STATUS=$?
          set -e

          if [ "${FMT_STATUS}" -ne 0 ]; then
            echo "[Terraform] Formatting issues detected (exit ${FMT_STATUS})."
            echo "----- BEGIN terraform fmt diff -----"
            echo "${FMT_OUTPUT}"
            echo "----- END terraform fmt diff -----"
            echo "Fix locally with:"
            echo "  terraform -chdir=\"${TF_DIR}\" fmt -recursive"
            exit "${FMT_STATUS}"   # usually 3 for fmt issues
          fi

          terraform -chdir="${TF_DIR}" validate -no-color
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        withCredentials([
          string(credentialsId: 'stage-apim-azure-subscription-id', variable: 'ARM_SUBSCRIPTION_ID'),
          string(credentialsId: 'stage-apim-azure-client',          variable: 'ARM_CLIENT_ID'),
          string(credentialsId: 'stage-apim-azure-secret',          variable: 'ARM_CLIENT_SECRET'),
          string(credentialsId: 'stage-apim-azure-tenant',          variable: 'ARM_TENANT_ID')
        ]) {
          sh '''
            #!/usr/bin/env bash
            set -e

            echo "[Plan] Checking bundled specs exist at: ${WORKSPACE}/build/api-bundled"
            ls -la "${WORKSPACE}/build/api-bundled" || { echo "ERROR: No bundled specs found"; exit 1; }

            terraform -chdir="${TF_DIR}" plan -input=false -no-color \
              -var="resource_group_name=${RESOURCE_GROUP_NAME_CRED}" \
              -var="api_management_name=${APIM_NAME_CRED}" \
              -out=tfplan.out
          '''
        }
      }
      post {
        always {
          archiveArtifacts artifacts: '**/tfplan.out', fingerprint: true
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        withCredentials([
          string(credentialsId: 'stage-apim-azure-subscription-id', variable: 'ARM_SUBSCRIPTION_ID'),
          string(credentialsId: 'stage-apim-azure-client',          variable: 'ARM_CLIENT_ID'),
          string(credentialsId: 'stage-apim-azure-secret',          variable: 'ARM_CLIENT_SECRET'),
          string(credentialsId: 'stage-apim-azure-tenant',          variable: 'ARM_TENANT_ID')
        ]) {
          sh '''
            #!/usr/bin/env bash
            set -e

            echo "[Apply] Applying plan..."
            terraform -chdir="${TF_DIR}" apply -input=false -no-color -auto-approve tfplan.out
          '''
        }
      }
    }
  }

  post {
    success { echo "Build succeeded. ${BUILD_URL}" }
    failure { echo "Build failed: ${BUILD_URL}" }
  }
}