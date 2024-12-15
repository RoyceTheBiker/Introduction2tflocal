output "bucket_name" {
  value = aws_s3_bucket.bucket-storage.bucket
}

output "roles" {
  value = {
    "S3_Access"     = aws_iam_role.S3_Access.name
  }
}