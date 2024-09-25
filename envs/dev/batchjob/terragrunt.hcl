include "root" {
  path = find_in_parent_folders()
}

dependency "docker" {
  config_path = "../docker"
  mock_outputs = {
    docker_registry_primary_image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-function:latest"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "batch" {
  config_path = "../batch"
  mock_outputs = {
    batch_job_iam_role_arn               = "arn:aws:iam::123456789012:role/my-batch-job-iam-role"
    batch_execution_iam_role_arn         = "arn:aws:iam::123456789012:role/my-batch-execution-iam-role"
    batch_cloudwatch_logs_log_group_name = "/aws/batch/job-logs"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  batch_image_uri                      = dependency.docker.outputs.docker_registry_primary_image_uri
  batch_job_iam_role_arn               = dependency.batch.outputs.batch_job_iam_role_arn
  batch_execution_iam_role_arn         = dependency.batch.outputs.batch_execution_iam_role_arn
  batch_cloudwatch_logs_log_group_name = dependency.batch.outputs.batch_cloudwatch_logs_log_group_name
}

terraform {
  source = "${get_repo_root()}/modules/batchjob"
}
