output "batch_compute_environment_fargate_ondemand_id" {
  description = "Batch compute environment for Fargate on-demand"
  value       = aws_batch_compute_environment.fargate["ondemand"].arn
}

output "batch_compute_environment_fargate_spot_id" {
  description = "Batch compute environment for Fargate spot"
  value       = aws_batch_compute_environment.fargate["spot"].arn
}

output "batch_compute_environment_ec2_ondemand_id" {
  description = "Batch compute environment for EC2 on-demand"
  value       = length(aws_batch_compute_environment.ec2) > 0 ? aws_batch_compute_environment.ec2["ondemand"].id : null
}

output "batch_compute_environment_ec2_spot_id" {
  description = "Batch compute environment for EC2 spot"
  value       = length(aws_batch_compute_environment.ec2) > 0 ? aws_batch_compute_environment.ec2["spot"].id : null
}

output "batch_ec2_launch_template_id" {
  description = "EC2 launch template ID"
  value       = length(aws_launch_template.ec2) > 0 ? aws_launch_template.ec2[0].id : null
}

output "batch_job_queue_fargate_ondemand_id" {
  description = "Batch job queue for Fargate on-demand"
  value       = aws_batch_job_queue.fargate["ondemand"].arn
}

output "batch_job_queue_fargate_spot_id" {
  description = "Batch job queue for Fargate spot"
  value       = aws_batch_job_queue.fargate["spot"].arn
}

output "batch_job_queue_ec2_ondemand_id" {
  description = "Batch job queue for EC2 on-demand"
  value       = length(aws_batch_job_queue.ec2) > 0 ? aws_batch_job_queue.ec2["ondemand"].arn : null
}

output "batch_job_queue_ec2_spot_id" {
  description = "Batch job queue for EC2 spot"
  value       = length(aws_batch_job_queue.ec2) > 0 ? aws_batch_job_queue.ec2["spot"].arn : null
}

output "Batch_cloudwatch_logs_log_group_name" {
  description = "Batch CloudWatch Logs log group name"
  value       = aws_cloudwatch_log_group.batch.name
}

output "batch_service_iam_role_arn" {
  description = "Batch service IAM role ARN"
  value       = aws_iam_role.service.arn
}

output "batch_execution_iam_role_arn" {
  description = "Batch execution IAM role ARN"
  value       = aws_iam_role.execution.arn
}

output "batch_job_iam_role_arn" {
  description = "Batch job IAM role ARN"
  value       = aws_iam_role.job.arn
}

output "batch_ec2_instance_role_arn" {
  description = "Batch EC2 instance role ARN"
  value       = length(aws_iam_role.ec2) > 0 ? aws_iam_role.ec2[0].arn : null
}

output "batch_ec2_iam_instance_profile_arn" {
  description = "Batch IAM instance profile ARN"
  value       = length(aws_iam_instance_profile.ec2) > 0 ? aws_iam_instance_profile.ec2[0].arn : null
}

output "batch_spotfleet_iam_role_arn" {
  description = "Batch spot fleet IAM role ARN"
  value       = length(aws_iam_role.spotfleet) > 0 ? aws_iam_role.spotfleet[0].arn : null
}

output "batch_client_iam_role_arn" {
  description = "Batch client IAM role ARN"
  value       = aws_iam_role.client.arn
}
