include "root" {
  path = find_in_parent_folders("root.hcl")
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
    private_subnet_ids        = ["subnet-12345678", "subnet-87654321"]
    private_security_group_id = "sg-12345678"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.subnet.outputs.private_subnet_ids
  security_group_ids = [dependency.subnet.outputs.private_security_group_id]
}

terraform {
  source = "git::https://github.com/dceoy/terraform-aws-vpc-for-slc.git//modules/vpce?ref=main"
}
