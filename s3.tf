
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.account_name}-releases"
  acl    = "private"

}
