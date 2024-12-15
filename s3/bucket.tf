data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "bucket-storage" {
        bucket  = "s3storage-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket-storage.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "bucket-policy" {
        bucket                  = "${aws_s3_bucket.bucket-storage.id}"
        depends_on      = [ aws_s3_bucket.bucket-storage ]

        policy = <<POLICY
{
        "Version":              "2012-10-17",
        "Statement":    [
                {
                        "Sid":                  "FineQualityHandCrafted0",
                        "Effect":               "Allow",
                        "Principal": {
                                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                        },
                        "Action": [
                                "s3:DeleteObject",
                                "s3:GetObject",
                                "s3:GetObjectAcl",
                                "s3:PutObject"
                        ],
                        "Resource":     "arn:aws:s3:::s3storage-${data.aws_caller_identity.current.account_id}/*"
                },
                {
                        "Sid": "FineQualityHandCrafted1",
                        "Effect": "Allow",
                        "Principal": {
                                        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                        },
                        "Action": [
                                "s3:ListBucket"
                        ],
                        "Resource": "arn:aws:s3:::s3storage-${data.aws_caller_identity.current.account_id}"
                }
        ]
}
POLICY
}
