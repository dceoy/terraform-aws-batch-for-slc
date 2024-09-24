include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/dceoy/terraform-aws-docker-based-lambda.git//modules/ecr?ref=main"
}
