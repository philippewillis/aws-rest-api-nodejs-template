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


# Get the Package Version (used for the )
APP_VERSION=$(cat package.json | jq -r '.version')
APP_NAME=$(cat package.json | jq -r '.name')
echo "$APP_NAME -> $APP_VERSION"

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
AWS_PROFILE="$AWS_PROFILE" terraform destroy \
  -var-file="$VAR_FILE" \
  -var="APP_NAME=$APP_NAME" \
  -var="APP_VERSION=$APP_VERSION" \
  -var="JWT_SECRET=$JWT_SECRET" \
  -var="JWT_TOKEN_EXPIRATION=$JWT_TOKEN_EXPIRATION" \
  -var="HOSTED_ZONE_NAME=$HOSTED_ZONE_NAME"

popd
