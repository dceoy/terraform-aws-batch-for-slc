locals {
  batch_job_definition_name_prefix = var.batch_job_definition_name_prefix != null ? var.batch_job_definition_name_prefix : "${var.system_name}-${var.env_type}-batch-job"
}
