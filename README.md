# AWS REST API Template
- Goal is to have a template to easily deploy an API Gateway REST API application
- Have Terraform deploy it
- The `package.json`'s version will be the version of the deployed API Gateway REST API.
- This REST API uses JWT to authenticate users, the `JWT_SECRET=""` in the `.env` file is used to sign JWT tokens.
- To mint a JWT token, use `pnpm run mint:token` to generate a JWT token.


## Run locally
- Test locally with `pnpm test`


## Deploy
- Deploy to dev
```shell
$ ./pipeline/deploy.sh <dev|staging|prod>
```

- Test it out with curl
```shell
$ pnpm mint:token

$ TOKEN="<KEY>"

$ BASE_URL="https://this-rocking-api-dev.some-awesome-site.com"
$ curl -X GET "$BASE_URL/hello" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json"
```
- You can test the deployment with [api.http](./api.http)




## AWS Services
- [x] API Gateway
- [x] Lambda - Proxy service
- [x] Lambda - Custom Authorizer
- [x] S3 - store the source code
- [x] ACM - Certs
- [x] Route53 - DNS
