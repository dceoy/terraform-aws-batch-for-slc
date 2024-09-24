include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id         = "vpc-12345678"
    vpc_cidr_block = "10.0.0.0/16"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  vpc_id         = dependency.vpc.outputs.vpc_id
  vpc_cidr_block = dependency.vpc.outputs.vpc_cidr_block
}

terraform {
  source = "git::https://github.com/dceoy/terraform-aws-vpc-for-slc.git//modules/subnet?ref=main"
}
