set -e

# Load environment variables (`APP_NAME`, `AWS_ACCOUNT_ID`, `AWS_PROFILE`, `TF_VERSION`)
source .env

# Environment
case "$1" in 
  dev)
    WORKSPACE=dev
    VAR_FILE=${2:-"env_configs/dev.tfvars"}
    ;;
  staging)
    WORKSPACE=staging
    VAR_FILE=${2:-"env_configs/staging.tfvars"}
    ;;
  prod)
    WORKSPACE=prod
    VAR_FILE=${2:-"env_configs/prod.tfvars"}
    ;;
  *)
    echo "Usage: $0 <dev|staging|prod> [var_file]"
    exit 1
    ;;
esac
echo "Using workspace: '$WORKSPACE' for Terraform deployment"

# TF version
if ! terraform version | grep -qF "$TF_VERSION"; then
  echo "Terraform version $TF_VERSION is required"
  exit 1
fi

rm -rf ./build ./dist
pnpm i
pnpm build


# Terraform init
pushd pipeline/terraform
# rm -rf .terraform
terraform_state_bucket="terraform-remote-state-$AWS_ACCOUNT_ID"
AWS_PROFILE="$AWS_PROFILE" terraform init -backend-config "bucket=${terraform_state_bucket}" -backend-config "key=${APP_NAME}"
echo "Using S3 bucket: $terraform_state_bucket for Terraform remote state"

# Create workspace if not exists
if ! AWS_PROFILE="$AWS_PROFILE" terraform workspace select $WORKSPACE; then
  AWS_PROFILE="$AWS_PROFILE" terraform workspace new $WORKSPACE
fi

# Plan
AWS_PROFILE="$AWS_PROFILE" terraform apply -auto-approve -var-file=$VAR_FILE -var="APP_NAME=$APP_NAME"
popd
