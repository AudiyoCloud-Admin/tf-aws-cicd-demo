output "ec2_public_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the instance"
  value       = aws_instance.web.public_dns
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket (if created)"
  value       = try(aws_s3_bucket.demo[0].bucket, null)
}
