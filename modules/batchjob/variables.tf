variable "batch_image_uri" {
  description = "Batch image URI"
  type        = string
}

variable "batch_job_iam_role_arn" {
  description = "Batch job IAM role ARN"
  type        = string
}

variable "batch_execution_iam_role_arn" {
  description = "Batch execution IAM role ARN"
  type        = string
}

variable "batch_cloudwatch_logs_log_group_name" {
  description = "Batch CloudWatch Logs log group name"
  type        = string
}

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

variable "batch_job_definition_name_prefix" {
  description = "Batch job definition name prefix"
  type        = string
  default     = null
}

variable "batch_job_definition_container_properties_command" {
  description = "Command in the container properties for Batch job definitions"
  type        = list(string)
  default     = []
}

variable "batch_job_definition_container_properties_environment" {
  description = "Environment variables in the container properties for Batch job definitions"
  type        = list(map(string))
  default     = []
}

variable "batch_job_definition_container_properties_resource_requirements_vcpus_fargate" {
  description = "Required FARGATE vCPUs in the container properties for Batch job definitions on Fargate"
  type        = number
  default     = 0.25
  validation {
    condition     = var.batch_job_definition_container_properties_resource_requirements_vcpus_fargate >= 0.25
    error_message = "Batch job definition required FARGATE vCPUs must be greater than or equal to 0.25"
  }
}

variable "batch_job_definition_container_properties_resource_requirements_memory_fargate" {
  description = "Required FARGATE memory in the container properties for Batch job definitions on Fargate"
  type        = number
  default     = 512
  validation {
    condition     = var.batch_job_definition_container_properties_resource_requirements_memory_fargate >= 512
    error_message = "Batch job definition required FARGATE memory must be greater than or equal to 512"
  }
}

variable "batch_job_definition_container_properties_resource_requirements_vcpus_ec2" {
  description = "Required EC2 vCPUs in the container properties for Batch job definitions on ec2"
  type        = number
  default     = 1
  validation {
    condition     = var.batch_job_definition_container_properties_resource_requirements_vcpus_ec2 >= 1
    error_message = "Batch job definition required EC2 vCPUs must be greater than or equal to 1"
  }
}

variable "batch_job_definition_container_properties_resource_requirements_memory_ec2" {
  description = "Required EC2 memory in the container properties for Batch job definitions on ec2"
  type        = number
  default     = 2048
  validation {
    condition     = var.batch_job_definition_container_properties_resource_requirements_memory_ec2 >= 2048
    error_message = "Batch job definition required EC2 memory must be greater than or equal to 2048"
  }
}

variable "batch_job_definition_container_properties_ephemeral_storage_size_in_gib" {
  description = "Ephemeral storage size in GiB in the container properties for Batch job definitions"
  type        = number
  default     = 200
  validation {
    condition     = var.batch_job_definition_container_properties_ephemeral_storage_size_in_gib >= 0
    error_message = "Ephemeral storage size in GiB in the container properties for Batch job definitions must be greater than or equal to 0"
  }
}

variable "batch_job_definition_retry_strategy_attempts" {
  description = "Retry strategy attempts on host EC2 failure for Batch job definitions"
  type        = number
  default     = 1
  validation {
    condition     = var.batch_job_definition_retry_strategy_attempts >= 1 && var.batch_job_definition_retry_strategy_attempts <= 10
    error_message = "Retry strategy attempts on host EC2 failure for Batch job definitions must be between 1 and 10"
  }
}

variable "batch_job_definition_timeout_attempt_duration_seconds" {
  description = "Timeout attempt duration in seconds for Batch job definitions"
  type        = number
  default     = 86400
  validation {
    condition     = var.batch_job_definition_timeout_attempt_duration_seconds >= 60
    error_message = "Timeout attempt duration in seconds for Batch job definitions must be greater than or equal to 60"
  }
}

variable "create_batch_ec2_job_definitions" {
  description = "Create Batch EC2 job definitions"
  type        = bool
  default     = true
}
