include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-12345678"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "subnet" {
  config_path = "../subnet"
  mock_outputs = {
    private_subnet_ids = ["subnet-12345678", "subnet-87654321"]
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.subnet.outputs.private_subnet_ids
  vpc_cidr_blocks = concat(
    [include.root.inputs.vpc_cidr_block],
    include.root.inputs.vpc_secondary_cidr_blocks
  )
}

terraform {
  source = "git::https://github.com/dceoy/terraform-aws-vpc-for-slc.git//modules/vpce?ref=main"
}
