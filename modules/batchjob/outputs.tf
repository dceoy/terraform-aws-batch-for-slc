output "batch_fargate_ondemand_job_definition_name" {
  description = "Batch job definition name for Fargate on-demand"
  value       = aws_batch_job_definition.fargate["ondemand"].arn
}

output "batch_fargate_spot_job_definition_name" {
  description = "Batch job definition name for Fargate spot"
  value       = aws_batch_job_definition.fargate["spot"].arn
}

output "batch_ec2_ondemand_job_definition_name" {
  description = "Batch job definition name for EC2 on-demand"
  value       = length(aws_batch_job_definition.ec2) > 0 ? aws_batch_job_definition.ec2["ondemand"].arn : null
}

output "batch_ec2_spot_job_definition_name" {
  description = "Batch job definition name for EC2 spot"
  value       = length(aws_batch_job_definition.ec2) > 0 ? aws_batch_job_definition.ec2["spot"].arn : null
}
