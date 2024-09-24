locals {
  account_id               = get_aws_account_id()
  region                   = run_cmd("--terragrunt-quiet", "aws", "configure", "get", "region")
  terraform_s3_bucket      = "tfstate-${local.region}-${local.account_id}"
  terraform_dynamodb_table = "tfstate-lock"
  system_name              = "slc"
  env_type                 = "dev"
  docker_image_build       = true
}
