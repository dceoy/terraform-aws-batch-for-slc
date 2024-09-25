locals {
  batch_job_definition_name_prefix = var.batch_job_definition_name_prefix != null ? var.batch_job_definition_name_prefix : split(":", split("/", var.batch_image_uri)[1])[0]
}
