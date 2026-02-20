include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    s3_iam_policy_arn = "arn:aws:iam::123456789012:policy/s3-iam-policy"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "subnet" {
  config_path = "../subnet"
  mock_outputs = {
    private_subnet_ids        = ["subnet-12345678", "subnet-87654321"]
    private_security_group_id = "sg-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  kms_key_arn                               = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  ec2_security_group_ids                    = [dependency.subnet.outputs.private_security_group_id]
  private_subnet_ids                        = dependency.subnet.outputs.private_subnet_ids
  batch_job_iam_role_managed_policy_arns    = [dependency.s3.outputs.s3_iam_policy_arn]
  batch_client_iam_role_managed_policy_arns = [dependency.s3.outputs.s3_iam_policy_arn]
}

terraform {
  source = "${get_repo_root()}/modules/batch"
}
