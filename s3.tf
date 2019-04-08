
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.project}-releases"
  acl    = "private"
  force_destroy = false
}

resource "aws_s3_bucket_policy" "releases" {
  bucket = "${aws_s3_bucket.codepipeline_bucket.id}"
  policy =<<POLICY
{
  "Id": "Policy1513880777555",
  "Version": "2012-10-17",
"Statement": [
{
      "Sid": "Stmt1513880773845",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
            "${aws_s3_bucket.codepipeline_bucket.arn}",
            "${aws_s3_bucket.codepipeline_bucket.arn}/*"
       ],
"Principal": {
"AWS": [
          "${aws_iam_role.codepipeline_role.arn}"
        
]
      
}
    
}
  
]

}
POLICY

}

