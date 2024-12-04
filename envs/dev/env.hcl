locals {
  account_id               = get_aws_account_id()
  region                   = get_env("AWS_REGION", get_env("AWS_DEFAULT_REGION", "us-east-1"))
  terraform_s3_bucket      = "tfstate-${local.region}-${local.account_id}"
  terraform_dynamodb_table = "tfstate-lock"
  system_name              = "slc"
  env_type                 = "dev"
  docker_image_build       = true
}
