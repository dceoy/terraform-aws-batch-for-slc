resource "aws_batch_job_definition" "fargate" {
  for_each              = toset(["ondemand", "spot"])
  name                  = "${local.batch_job_definition_name_prefix}-on-fargate-${each.key}"
  platform_capabilities = ["FARGATE"]
  type                  = "container"
  propagate_tags        = true
  container_properties = jsonencode({
    image            = var.batch_image_uri
    jobRoleArn       = var.batch_job_iam_role_arn
    executionRoleArn = var.batch_execution_iam_role_arn
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group = var.batch_cloudwatch_logs_log_group_name
      }
    }
    command     = var.batch_job_definition_container_properties_command
    environment = var.batch_job_definition_container_properties_environment
    resourceRequirements = [
      {
        type  = "VCPU"
        value = tostring(var.batch_job_definition_container_properties_resource_requirements_vcpus_fargate)
      },
      {
        type  = "MEMORY"
        value = tostring(var.batch_job_definition_container_properties_resource_requirements_memory_fargate)
      }
    ]
    ephemeralStorage = {
      sizeInGiB = var.batch_job_definition_container_properties_ephemeral_storage_size_in_gib
    }
    fargatePlatformConfiguration = {
      platformVersion = "LATEST"
    }
    networkConfiguration = {
      assignPublicIp = "DISABLED"
    }
    privileged             = false
    readonlyRootFilesystem = false
  })
  retry_strategy {
    attempts = var.batch_job_definition_retry_strategy_attempts
    evaluate_on_exit {
      on_status_reason = "Host EC2*"
      action           = "RETRY"
    }
    evaluate_on_exit {
      on_reason = "*"
      action    = "EXIT"
    }
  }
  timeout {
    attempt_duration_seconds = var.batch_job_definition_timeout_attempt_duration_seconds
  }
  tags = {
    Name       = "${local.batch_job_definition_name_prefix}-on-fargate-${each.key}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_batch_job_definition" "ec2" {
  for_each              = toset(var.create_batch_ec2_job_definitions ? ["ondemand", "spot"] : [])
  name                  = "${local.batch_job_definition_name_prefix}-on-ec2-${each.key}"
  platform_capabilities = ["EC2"]
  type                  = "container"
  propagate_tags        = true
  container_properties = jsonencode({
    image            = var.batch_image_uri
    jobRoleArn       = var.batch_job_iam_role_arn
    executionRoleArn = var.batch_execution_iam_role_arn
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group = var.batch_cloudwatch_logs_log_group_name
      }
    }
    command     = var.batch_job_definition_container_properties_command
    environment = var.batch_job_definition_container_properties_environment
    resourceRequirements = [
      {
        type  = "VCPU"
        value = tostring(var.batch_job_definition_container_properties_resource_requirements_vcpus_ec2)
      },
      {
        type  = "MEMORY"
        value = tostring(var.batch_job_definition_container_properties_resource_requirements_memory_ec2)
      }
    ]
    networkConfiguration = {
      assignPublicIp = "DISABLED"
    }
    privileged             = false
    readonlyRootFilesystem = false
  })
  retry_strategy {
    attempts = var.batch_job_definition_retry_strategy_attempts
    evaluate_on_exit {
      on_status_reason = "Host EC2*"
      action           = "RETRY"
    }
    evaluate_on_exit {
      on_reason = "*"
      action    = "EXIT"
    }
  }
  timeout {
    attempt_duration_seconds = var.batch_job_definition_timeout_attempt_duration_seconds
  }
  tags = {
    Name       = "${local.batch_job_definition_name_prefix}-on-ec2-${each.key}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
