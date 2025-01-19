include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::https://github.com/dceoy/terraform-aws-docker-based-lambda.git//modules/ecr?ref=main"
}
