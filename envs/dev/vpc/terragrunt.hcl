include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    awslogs_s3_bucket_id = "awslogs-s3-bucket-id"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  vpc_flow_log_s3_bucket_id = dependency.s3.outputs.awslogs_s3_bucket_id
}

terraform {
  source = "git::https://github.com/dceoy/terraform-aws-vpc-for-slc.git//modules/vpc?ref=main"
}
