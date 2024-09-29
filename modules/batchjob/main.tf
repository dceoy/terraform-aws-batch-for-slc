resource "aws_batch_job_definition" "fargate" {
  name                  = "${local.batch_job_definition_name_prefix}-on-fargate"
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
    command = var.batch_job_definition_container_properties_command
    environment = [
      for k, v in var.batch_job_definition_container_properties_environment_variables : {
        name  = k
        value = v
      }
    ]
    runtimePlatform = {
      cpuArchitecture       = var.batch_job_definition_container_properties_runtime_platform_cpu_architecture
      operatingSystemFamily = "LINUX"
    }
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
  dynamic "retry_strategy" {
    for_each = var.batch_job_definition_retry_strategy_attempts > 0 ? [true] : []
    content {
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
  }
  dynamic "timeout" {
    for_each = var.batch_job_definition_timeout_attempt_duration_seconds > 0 ? [true] : []
    content {
      attempt_duration_seconds = var.batch_job_definition_timeout_attempt_duration_seconds
    }
  }
  tags = {
    Name       = "${local.batch_job_definition_name_prefix}-on-fargate"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_batch_job_definition" "ec2" {
  count                 = var.create_batch_ec2_job_definitions ? 1 : 0
  name                  = "${local.batch_job_definition_name_prefix}-on-ec2"
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
    command = var.batch_job_definition_container_properties_command
    environment = [
      for k, v in var.batch_job_definition_container_properties_environment_variables : {
        name  = k
        value = v
      }
    ]
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
  dynamic "retry_strategy" {
    for_each = var.batch_job_definition_retry_strategy_attempts > 0 ? [true] : []
    content {
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
  }
  dynamic "timeout" {
    for_each = var.batch_job_definition_timeout_attempt_duration_seconds > 0 ? [true] : []
    content {
      attempt_duration_seconds = var.batch_job_definition_timeout_attempt_duration_seconds
    }
  }
  tags = {
    Name       = "${local.batch_job_definition_name_prefix}-on-ec2"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
