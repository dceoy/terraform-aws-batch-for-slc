output "batch_fargate_ondemand_job_definition_arn" {
  description = "Batch job definition ARN for Fargate"
  value       = aws_batch_job_definition.fargate.arn
}

output "batch_fargate_ondemand_job_definition_arn_prefix" {
  description = "Batch job definition ARN prefix for Fargate"
  value       = aws_batch_job_definition.fargate.arn_prefix
}

output "batch_fargate_ondemand_job_definition_revision" {
  description = "Batch job definition revision for Fargate"
  value       = aws_batch_job_definition.fargate.revision
}

output "batch_ec2_ondemand_job_definition_arn" {
  description = "Batch job definition ARN for EC2"
  value       = length(aws_batch_job_definition.ec2) > 0 ? aws_batch_job_definition.ec2[0].arn : null
}

output "batch_ec2_ondemand_job_definition_arn_prefix" {
  description = "Batch job definition ARN prefix for EC2"
  value       = length(aws_batch_job_definition.ec2) > 0 ? aws_batch_job_definition.ec2[0].arn_prefix : null
}

output "batch_ec2_ondemand_job_definition_revision" {
  description = "Batch job definition revision for EC2"
  value       = length(aws_batch_job_definition.ec2) > 0 ? aws_batch_job_definition.ec2[0].revision : null
}
