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


# Build source files
rm -rf ./build ./dist
pnpm i
pnpm build


LAMBDA_FUNCTION_NAME="$APP_NAME-$WORKSPACE"
echo "Zip the source files..."
pushd build
zip -r ../build.zip *
popd
AWS_PROFILE="$AWS_PROFILE" aws lambda update-function-code --function-name $LAMBDA_FUNCTION_NAME --zip-file fileb://build.zip --region us-west-2
rm -rf build.zip
echo "AWS Lambda source synced!!"