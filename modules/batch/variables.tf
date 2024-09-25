variable "system_name" {
  description = "System name"
  type        = string
  default     = "slc"
}

variable "env_type" {
  description = "Environment type"
  type        = string
  default     = "dev"
}

variable "cloudwatch_logs_retention_in_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 30
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_logs_retention_in_days)
    error_message = "CloudWatch Logs retention in days must be 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 or 0 (zero indicates never expire logs)"
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any IAM policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "ec2_launch_template_block_device_mappings_device_name" {
  description = "Device name for the EC2 launch template block device mappings"
  type        = string
  default     = "/dev/xvda"
}

variable "ec2_launch_template_block_device_mappings_ebs_volume_size" {
  description = "EC2 launch template EBS volume size in GB"
  type        = number
  default     = 1024
}

variable "ec2_launch_template_block_device_mappings_ebs_volume_type" {
  description = "EC2 launch template EBS volume type"
  type        = string
  default     = "gp3"
}

variable "ec2_launch_template_block_device_mappings_ebs_iops" {
  description = "EC2 launch template EBS IOPS"
  type        = number
  default     = null
}

variable "ec2_launch_template_block_device_mappings_ebs_throughput" {
  description = "EC2 launch template EBS throughput in MiB/s"
  type        = number
  default     = null
}

variable "ec2_instance_types" {
  description = "EC2 instance types"
  type        = list(string)
  default     = []
}

variable "ec2_security_group_ids" {
  description = "EC2 security group IDs"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "VPC private subnet IDs"
  type        = list(string)
  default     = []
}

variable "batch_job_iam_role_managed_policy_arns" {
  description = "IAM role managed policy ARNs for the Batch job IAM role"
  type        = list(string)
  default     = []
}

variable "batch_compute_environment_compute_resources_max_vcpus" {
  description = "Maximum vCPUs for the Batch compute environment compute resources"
  type        = number
  default     = 256
  validation {
    condition     = var.batch_compute_environment_compute_resources_max_vcpus > 0
    error_message = "Maximum vCPUs for the Batch compute environment compute resources must be greater than 0"
  }
}

variable "batch_compute_environment_compute_resources_min_vcpus" {
  description = "Minimum vCPUs for the Batch compute environment compute resources"
  type        = number
  default     = 0
  validation {
    condition     = var.batch_compute_environment_compute_resources_min_vcpus >= 0
    error_message = "Minimum vCPUs for the Batch compute environment compute resources must be greater than or equal to 0"
  }
}

variable "batch_compute_environment_compute_resources_allocation_strategy_ondemand" {
  description = "On-demand allocation strategy for the Batch compute environment compute resources"
  type        = string
  default     = "BEST_FIT"
  validation {
    condition     = var.batch_compute_environment_compute_resources_allocation_strategy_ondemand == "BEST_FIT" || var.batch_compute_environment_compute_resources_allocation_strategy_ondemand == "BEST_FIT_PROGRESSIVE"
    error_message = "On-demand allocation strategy for the Batch compute environment compute resources must be BEST_FIT or BEST_FIT_PROGRESSIVE"
  }
}

variable "batch_compute_environment_compute_resources_allocation_strategy_spot" {
  description = "Spot allocation strategy for the Batch compute environment compute resources"
  type        = string
  default     = "SPOT_CAPACITY_OPTIMIZED"
  validation {
    condition     = var.batch_compute_environment_compute_resources_allocation_strategy_spot == "SPOT_CAPACITY_OPTIMIZED" || var.batch_compute_environment_compute_resources_allocation_strategy_spot == "SPOT_PRICE_CAPACITY_OPTIMIZED" || var.batch_compute_environment_compute_resources_allocation_strategy_spot == "BEST_FIT" || var.batch_compute_environment_compute_resources_allocation_strategy_spot == "BEST_FIT_PROGRESSIVE"
    error_message = "Spot allocation strategy for the Batch compute environment compute resources must be SPOT_CAPACITY_OPTIMIZED, SPOT_PRICE_CAPACITY_OPTIMIZED, BEST_FIT, or BEST_FIT_PROGRESSIVE"
  }
}

variable "batch_compute_environment_compute_resources_bid_percentage" {
  description = "Spot bid percentage for the Batch compute environment compute resources"
  type        = number
  default     = 100
  validation {
    condition     = var.batch_compute_environment_compute_resources_bid_percentage > 0 && var.batch_compute_environment_compute_resources_bid_percentage <= 100
    error_message = "Spot bid percentage for the Batch compute environment compute resources must be greater than 0 and less than or equal to 100"
  }
}

variable "batch_compute_environment_compute_resources_desired_vcpus" {
  description = "Desired EC2 vCPUs for the Batch compute environment compute resources"
  type        = number
  default     = null
}

variable "batch_compute_environment_compute_resources_ec2_configuration_image_type" {
  description = "EC2 configuration image type for the Batch compute environment (e.g., ECS_AL2, or ECS_AL2_NVIDIA)"
  type        = string
  default     = "ECS_AL2"
}

variable "batch_compute_environment_compute_resources_launch_template_version" {
  description = "Launch template version for the Batch compute environment"
  type        = string
  default     = "$Latest"
}

variable "batch_compute_environment_compute_resources_placement_group" {
  description = "EC2 placement group for the Batch compute environment compute resources"
  type        = string
  default     = null
}

variable "batch_compute_environment_update_policy_job_execution_timeout_minutes" {
  description = "Job execution timeout in minutes for the Batch compute environment update policy"
  type        = number
  default     = 30
  validation {
    condition     = var.batch_compute_environment_update_policy_job_execution_timeout_minutes > 0 && var.batch_compute_environment_update_policy_job_execution_timeout_minutes <= 360
    error_message = "Job execution timeout in minutes for the Batch compute environment update policy must be between 1 and 360"
  }
}

variable "batch_compute_environment_update_policy_terminate_jobs_on_update" {
  description = "Whether to terminate jobs on update for the Batch compute environment update policy"
  type        = bool
  default     = false
}

variable "batch_job_queue_job_state_time_limit_action_max_time_seconds" {
  description = "Maximum time in seconds for the Batch job queue job state time limit action"
  type        = number
  default     = 86400
  validation {
    condition     = var.batch_job_queue_job_state_time_limit_action_max_time_seconds >= 600 && var.batch_job_queue_job_state_time_limit_action_max_time_seconds <= 86400
    error_message = "Maximum time in seconds for the Batch job queue job state time limit action must be between 600 and 86400"
  }
}

variable "batch_client_iam_role_max_session_duration" {
  description = "IAM role maximum session duration for the Batch client IAM role"
  type        = number
  default     = 3600
  validation {
    condition     = var.batch_client_iam_role_max_session_duration >= 3600 && var.batch_client_iam_role_max_session_duration <= 43200
    error_message = "IAM role maximum session duration must be between 3600 and 43200"
  }
}

variable "batch_client_iam_role_managed_policy_arns" {
  description = "IAM role managed policy ARNs for the Batch client IAM role"
  type        = list(string)
  default     = []
}
