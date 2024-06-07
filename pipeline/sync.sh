cset -e

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


# Build the source code
rm -rf ./build ./dist ./build-authorizer
pnpm i
pnpm build

PROJECT_NAME="this-rocking-api-$WORKSPACE"

LAMBDA_FUNCITON_NAME="$PROJECT_NAME"
echo "Zipping source files..."
pushd build
zip -r ../build.zip *
popd
AWS_PROFILE="$AWS_PROFILE" aws lambda update-function-code --function-name $LAMBDA_FUNCITON_NAME --zip-file fileb://build.zip --region us-west-2
rm -rf build.zip
echo "Updated $LAMBDA_FUNCITON_NAME Lambda function"


LAMBDA_AUTH_FUNCITON_NAME="$PROJECT_NAME-custom-authorizer"
echo "Zipping source files..."
pushd custom-authorizer
zip -r ../custom-authorizer.zip *
popd
AWS_PROFILE="$AWS_PROFILE" aws lambda update-function-code --function-name $LAMBDA_AUTH_FUNCITON_NAME --zip-file fileb://custom-authorizer.zip --region us-west-2
rm -rf custom-authorizer.zip
echo "Updated $LAMBDA_AUTH_FUNCITON_NAME Lambda function"


echo "DONE"