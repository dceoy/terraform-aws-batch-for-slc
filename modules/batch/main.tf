resource "aws_batch_compute_environment" "fargate" {
  for_each = {
    ondemand = "FARGATE"
    spot     = "FARGATE_SPOT"
  }
  compute_environment_name = "${var.system_name}-${var.env_type}-batch-compute-environment-fargate-${each.key}"
  type                     = "MANAGED"
  state                    = "ENABLED"
  service_role             = aws_iam_role.service.arn
  compute_resources {
    type               = each.value
    subnets            = var.private_subnet_ids
    security_group_ids = var.ec2_security_group_ids
    max_vcpus          = var.batch_compute_environment_compute_resources_max_vcpus
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-batch-compute-environment-fargate-${each.key}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_batch_compute_environment" "ec2" {
  for_each = length(aws_iam_instance_profile.ec2) > 0 ? {
    ondemand = "EC2"
    spot     = "SPOT"
  } : {}
  compute_environment_name = "${var.system_name}-${var.env_type}-batch-compute-environment-ec2-${each.key}"
  type                     = "MANAGED"
  state                    = "ENABLED"
  service_role             = aws_iam_role.service.arn
  compute_resources {
    type                = each.value
    subnets             = var.private_subnet_ids
    security_group_ids  = var.ec2_security_group_ids
    max_vcpus           = var.batch_compute_environment_compute_resources_max_vcpus
    min_vcpus           = var.batch_compute_environment_compute_resources_min_vcpus
    instance_role       = aws_iam_instance_profile.ec2[0].arn
    instance_type       = var.batch_compute_environment_compute_resources_instance_type
    allocation_strategy = each.key == "spot" ? var.batch_compute_environment_compute_resources_allocation_strategy_spot : var.batch_compute_environment_compute_resources_allocation_strategy_ondemand
    desired_vcpus       = var.batch_compute_environment_compute_resources_desired_vcpus
    placement_group     = var.batch_compute_environment_compute_resources_placement_group
    bid_percentage      = each.key == "spot" ? var.batch_compute_environment_compute_resources_bid_percentage : null
    spot_iam_fleet_role = each.key == "spot" ? aws_iam_role.spotfleet[0].arn : null
    ec2_configuration {
      image_type = var.batch_compute_environment_compute_resources_ec2_configuration_image_type
    }
    launch_template {
      launch_template_id = aws_launch_template.ec2[0].id
      version            = var.batch_compute_environment_compute_resources_launch_template_version
    }
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-batch-compute-environment-ec2-${each.key}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_launch_template" "ec2" {
  count = length(aws_iam_instance_profile.ec2) > 0 ? 1 : 0
  name  = "${var.system_name}-${var.env_type}-ec2-launch-template"
  block_device_mappings {
    device_name = var.ec2_launch_template_block_device_mappings_device_name
    ebs {
      volume_size           = var.ec2_launch_template_block_device_mappings_ebs_volume_size
      volume_type           = var.ec2_launch_template_block_device_mappings_ebs_volume_type
      iops                  = var.ec2_launch_template_block_device_mappings_ebs_iops
      throughput            = var.ec2_launch_template_block_device_mappings_ebs_throughput
      encrypted             = true
      delete_on_termination = true
    }
  }
  metadata_options {
    http_tokens = "required"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      LaunchTemplateName = "${var.system_name}-${var.env_type}-ec2-launch-template"
      SystemName         = var.system_name
      EnvType            = var.env_type
    }
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-ec2-launch-template"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_batch_job_queue" "fargate" {
  for_each = aws_batch_compute_environment.fargate
  name     = "${var.system_name}-${var.env_type}-batch-job-queue-fargate-${each.key}"
  state    = "ENABLED"
  priority = 1
  compute_environment_order {
    order               = 1
    compute_environment = each.value.arn
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-batch-job-queue-fargate-${each.key}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_batch_job_queue" "ec2" {
  for_each = aws_batch_compute_environment.ec2
  name     = "${var.system_name}-${var.env_type}-batch-job-queue-ec2-${each.key}"
  state    = "ENABLED"
  priority = 1
  compute_environment_order {
    order               = 1
    compute_environment = each.value.arn
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-batch-job-queue-ec2-${each.key}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

# trivy:ignore:avd-aws-0017
resource "aws_cloudwatch_log_group" "batch" {
  name              = "/${var.system_name}/${var.env_type}/batch"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/batch"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role" "service" {
  name                  = "${var.system_name}-${var.env_type}-batch-service-iam-role"
  description           = "Batch service IAM role"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBatchServiceToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "batch.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
  ]
  tags = {
    Name    = "${var.system_name}-${var.env_type}-batch-service-iam-role"
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_iam_role" "execution" {
  name                  = "${var.system_name}-${var.env_type}-batch-execution-iam-role"
  description           = "Batch execution IAM role"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTasksToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
  tags = {
    Name    = "${var.system_name}-${var.env_type}-batch-execution-iam-role"
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_iam_role_policy" "kms" {
  count = var.kms_key_arn != null ? 1 : 0
  name  = "${var.system_name}-${var.env_type}-batch-execution-iam-role-policy"
  role  = aws_iam_role.execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowKMSAccess"
        Effect   = "Allow"
        Action   = ["kms:GenerateDataKey"]
        Resource = [var.kms_key_arn]
      }
    ]
  })
}

resource "aws_iam_role" "job" {
  name                  = "${var.system_name}-${var.env_type}-batch-job-iam-role"
  description           = "Batch job IAM role"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTasksToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = var.batch_job_iam_role_managed_policy_arns
  tags = {
    Name    = "${var.system_name}-${var.env_type}-batch-job-iam-role"
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_iam_role" "ec2" {
  count                 = length(var.batch_compute_environment_compute_resources_instance_type) > 0 ? 1 : 0
  name                  = "${var.system_name}-${var.env_type}-batch-ec2-instance-iam-role"
  description           = "Batch EC2 instance IAM role"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2ToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]
  tags = {
    Name    = "${var.system_name}-${var.env_type}-batch-ec2-instance-iam-role"
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_iam_instance_profile" "ec2" {
  count = length(aws_iam_role.ec2) > 0 ? 1 : 0
  name  = "${var.system_name}-${var.env_type}-batch-iam-instance-profile"
  role  = aws_iam_role.ec2[count.index].name
  path  = "/"
  tags = {
    Name       = "${var.system_name}-${var.env_type}-batch-iam-instance-profile"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role" "spotfleet" {
  count                 = length(aws_iam_role.ec2) > 0 ? 1 : 0
  name                  = "${var.system_name}-${var.env_type}-batch-spotfleet-iam-role"
  description           = "Batch spot-fleet IAM role"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSpotFleetToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "spotfleet.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
  ]
  tags = {
    Name    = "${var.system_name}-${var.env_type}-batch-spotfleet-iam-role"
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_iam_role" "client" {
  name                  = "${var.system_name}-${var.env_type}-batch-client-iam-role"
  description           = "Batch client IAM role"
  force_detach_policies = true
  path                  = "/"
  max_session_duration  = var.batch_client_iam_role_max_session_duration
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRootAccountToAssumeRole"
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
      }
    ]
  })
  managed_policy_arns = var.batch_client_iam_role_managed_policy_arns
  tags = {
    Name    = "${var.system_name}-${var.env_type}-batch-client-iam-role"
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_iam_role_policy" "client" {
  name = "${var.system_name}-${var.env_type}-batch-client-iam-role-policy"
  role = aws_iam_role.client.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "batch:Describe*",
            "batch:List*"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowBatchJobActions"
          Effect = "Allow"
          Action = [
            "batch:CancelJob",
            "batch:SubmitJob",
            "batch:TerminateJob"
          ]
          Resource = [
            "arn:aws:batch:${local.region}:${local.account_id}:job-definition/*",
            "arn:aws:batch:${local.region}:${local.account_id}:job-queue/*",
            "arn:aws:batch:${local.region}:${local.account_id}:job/*"
          ]
          Condition = {
            StringEquals = {
              "aws:ResourceTag/SystemName" = var.system_name
              "aws:ResourceTag/EnvType"    = var.env_type
            }
          }
        },
        {
          Sid    = "AllowCloudWatchLogsReadOnlyAccess"
          Effect = "Allow"
          Action = [
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:GetLogEvents",
            "logs:FilterLogEvents",
            "logs:StartQuery",
            "logs:StopQuery",
            "logs:DescribeQueries",
            "logs:GetLogGroupFields",
            "logs:GetLogRecord",
            "logs:GetQueryResults"
          ]
          Resource = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:*"]
          Condition = {
            StringEquals = {
              "aws:ResourceTag/SystemName" = var.system_name
              "aws:ResourceTag/EnvType"    = var.env_type
            }
          }
        },
      ],
      (
        var.kms_key_arn != null ? [
          {
            Sid      = "AllowKMSDecrypt"
            Effect   = "Allow"
            Action   = ["kms:Decrypt"]
            Resource = [var.kms_key_arn]
          }
        ] : []
      )
    )
  })
}
