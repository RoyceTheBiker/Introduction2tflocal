# Roles connect policies to resources. This will demonstrate by allowing an instance
# to have access to an S3 storage without saving credentials on the instance.

# Separating the policy from the role allows for attaching different policies in
# various combinations to each instance.
resource "aws_iam_role" "S3_Access" {
  name            = "S3_Access"
  description     = "Access to S3 storage without having credentials on the instance"

  assume_role_policy = jsonencode({
    "Version":              "2012-10-17",
    "Statement":    [
      {
        "Action":       "sts:AssumeRole",
        "Effect":       "Allow",
        "Principal":    {
          "Service":      "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "S3_Access" {
  name            = "S3_Access"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid":          "ShowMeTheData"
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket",
          "s3:ListAllMyBuckets"
        ],
        "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket-storage.bucket}"
      },
      {
        "Sid":          "AllYourDataAreBelongToUs",
        "Effect": "Allow",
        "Action":       [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:PutObject",
          "s3:PutObjectTagging",
          "s3:PutObjectVersionAcl",
          "s3:PutObjectVersionTagging"
        ],
        "Resource":     "arn:aws:s3:::${aws_s3_bucket.bucket-storage.bucket}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "S3_Access" {
  role = aws_iam_role.S3_Access.name
  policy_arn = aws_iam_policy.S3_Access.arn
}

resource "aws_iam_instance_profile" "S3_Access" {
  name = "S3_Access"
  role = aws_iam_role.S3_Access.name
}