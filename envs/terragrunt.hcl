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
    "github.com/dceoy/submodules/terraform-aws-vpc-for-slc",
    "github.com/dceoy/submodules/terraform-aws-docker-based-lambda",
    "${local.repo_root}/modules/batch"
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
  private_subnet_count                      = 1
  public_subnet_count                       = 1
  subnet_newbits                            = 8
  nat_gateway_count                         = 0
  vpc_interface_endpoint_services = [
    "ecr.dkr", "ecr.api", "ecs", "ecs-agent", "ecs-telemetry", "logs", "kms", "secretsmanager"
  ]
  ecr_repository_name                                                      = local.image_name
  ecr_image_secondary_tags                                                 = compact(split(",", get_env("DOCKER_METADATA_OUTPUT_TAGS", "latest")))
  ecr_image_tag_mutability                                                 = "MUTABLE"
  ecr_force_delete                                                         = true
  ecr_lifecycle_policy_image_count                                         = 1
  docker_image_force_remove                                                = true
  docker_image_build                                                       = local.env_vars.locals.docker_image_build
  docker_image_build_context                                               = "${local.repo_root}/docker"
  docker_image_build_dockerfile                                            = "Dockerfile"
  docker_image_build_build_args                                            = {}
  docker_image_build_platform                                              = "linux/arm64"
  docker_image_primary_tag                                                 = get_env("DOCKER_PRIMARY_TAG", run_cmd("--terragrunt-quiet", "git", "rev-parse", "--short", "HEAD"))
  docker_host                                                              = get_env("DOCKER_HOST", "unix:///var/run/docker.sock")
  cloudwatch_logs_retention_in_days                                        = 30
  iam_role_force_detach_policies                                           = true
  ec2_launch_template_block_device_mappings_device_name                    = "/dev/xvda"
  ec2_launch_template_block_device_mappings_ebs_volume_size                = 1024
  ec2_launch_template_block_device_mappings_ebs_volume_type                = "gp3"
  ec2_instance_types                                                       = ["m7g", "c7g", "r7g", "r8g"]
  batch_compute_environment_compute_resources_max_vcpus                    = 256
  batch_compute_environment_compute_resources_min_vcpus                    = 0
  batch_compute_environment_compute_resources_allocation_strategy_ondemand = "BEST_FIT"
  batch_compute_environment_compute_resources_allocation_strategy_spot     = "SPOT_CAPACITY_OPTIMIZED"
  batch_compute_environment_compute_resources_spot_bid_percentage          = 100
  batch_compute_environment_ec2_configuration_image_type                   = "ECS_AL2"
  batch_compute_environment_launch_template_version                        = "$Latest"
  batch_compute_environment_update_policy_job_execution_timeout_minutes    = 30
  batch_compute_environment_update_policy_terminate_jobs_on_update         = false
  batch_job_queue_job_state_time_limit_action_max_time_seconds             = 86400
  batch_client_iam_role_max_session_duration                               = 3600
}
