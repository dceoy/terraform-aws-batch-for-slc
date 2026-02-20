include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "subnet" {
  config_path = "../subnet"
  mock_outputs = {
    private_route_table_ids = ["rtb-12345678", "rtb-87654321"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  vpc_id                  = dependency.vpc.outputs.vpc_id
  private_route_table_ids = dependency.subnet.outputs.private_route_table_ids
}

terraform {
  source = "git::https://github.com/dceoy/terraform-aws-vpc-for-slc.git//modules/nat?ref=main"
}
