include "root" {
  path = find_in_parent_folders()
}

dependency "ecr" {
  config_path = "../ecr"
  mock_outputs = {
    ecr_repository_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-function"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  ecr_repository_url = dependency.ecr.outputs.ecr_repository_url
}

terraform {
  source = "git::https://github.com/dceoy/terraform-aws-docker-based-lambda.git//modules/docker?ref=main"
}
