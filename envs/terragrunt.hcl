locals {
  image_name = "batch-hello-world"
  docker_image_build_platforms = {
    "x86_64" = "linux/amd64"
    "arm64"  = "linux/arm64"
  }
  repo_root   = get_repo_root()
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  ecr_address = "${local.env_vars.locals.account_id}.dkr.ecr.${local.env_vars.locals.region}.amazonaws.com"
}

terraform {
  extra_arguments "parallelism" {
    commands = get_terraform_commands_that_need_parallelism()
    arguments = [
      "-parallelism=16"
    ]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = local.env_vars.locals.terraform_s3_bucket
    key            = "${basename(local.repo_root)}/${local.env_vars.locals.system_name}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.env_vars.locals.region
    encrypt        = true
    dynamodb_table = local.env_vars.locals.terraform_dynamodb_table
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.env_vars.locals.region}"
  default_tags {
    tags = {
      SystemName = "${local.env_vars.locals.system_name}"
      EnvType    = "${local.env_vars.locals.env_type}"
    }
  }
}
EOF
}

catalog {
  urls = [
    "${local.repo_root}/modules/kms",
    "${local.repo_root}/modules/s3",
    "github.com/dceoy/submodules/terraform-aws-vpc-for-slc",
    "github.com/dceoy/submodules/terraform-aws-docker-based-lambda",
    # "${local.repo_root}/modules/batch"
  ]
}

inputs = {
  system_name                               = local.env_vars.locals.system_name
  env_type                                  = local.env_vars.locals.env_type
  create_kms_key                            = true
  kms_key_deletion_window_in_days           = 30
  kms_key_rotation_period_in_days           = 365
  create_io_s3_bucket                       = true
  create_awslogs_s3_bucket                  = true
  s3_force_destroy                          = true
  s3_noncurrent_version_expiration_days     = 7
  s3_abort_incomplete_multipart_upload_days = 7
  s3_expired_object_delete_marker           = true
  enable_s3_server_access_logging           = true
  vpc_cidr_block                            = "10.0.0.0/16"
  vpc_secondary_cidr_blocks                 = []
  cloudwatch_logs_retention_in_days         = 30
  private_subnet_count                      = 1
  public_subnet_count                       = 1
  subnet_newbits                            = 8
  nat_gateway_count                         = 0
  vpc_interface_endpoint_services = [
    "ecr.dkr", "ecr.api", "ecs", "ecs-agent", "ecs-telemetry",
    "logs", "kms", "secretsmanager"
  ]
  ecr_repository_name               = local.image_name
  ecr_image_secondary_tags          = compact(split(",", get_env("DOCKER_METADATA_OUTPUT_TAGS", "latest")))
  ecr_image_tag_mutability          = "MUTABLE"
  ecr_force_delete                  = true
  ecr_lifecycle_policy_image_count  = 1
  docker_image_force_remove         = true
  docker_image_build                = local.env_vars.locals.docker_image_build
  docker_image_build_context        = "${local.repo_root}/docker"
  docker_image_build_dockerfile     = "Dockerfile"
  docker_image_build_build_args     = {}
  docker_image_build_platform       = "linux/arm64"
  docker_image_primary_tag          = get_env("DOCKER_PRIMARY_TAG", run_cmd("--terragrunt-quiet", "git", "rev-parse", "--short", "HEAD"))
  docker_host                       = get_env("DOCKER_HOST", "unix:///var/run/docker.sock")
  cloudwatch_logs_retention_in_days = 30
  iam_role_force_detach_policies    = true
}
