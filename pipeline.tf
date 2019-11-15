
// data "aws_kms_alias" "s3kmskey" {
//   name = "alias/myKmsKey"
// }

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project}"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
    type     = "S3"

    // encryption_key {
    //   id   = "${data.aws_kms_alias.s3kmskey.arn}"
    //   type = "KMS"
    // }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner  = "${var.github_org}"
        Repo   = "${var.project}"
        Branch = "master"
        PollForSourceChanges = "true"
        OAuthToken           = "${var.github_token}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.project.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CloudFormation"
      input_artifacts  = ["build_output"]
      version          = "1"

      configuration {
        ActionMode     = "REPLACE_ON_FAILURE"
        Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
        OutputFileName = "CreateStackOutput.json"
        StackName      = "MyStack"
        TemplatePath   = "build_output::sam-templated.yaml"
      }
    }
  }
}




// locals {
//   webhook_secret = ""${data. aws_ssm_parameter.foo.value}""
// }

data "aws_ssm_parameter" "webhook_secret" {
   name = "/${var.project}/webhook_secret"
}

data "github_repository" "example" {
  full_name = "swisstopo-test/terraform-codepipeline-example"
}

resource "aws_codepipeline_webhook" "bar" {
  name            = "test-webhook-github-bar"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = "${aws_codepipeline.codepipeline.name}"

  authentication_configuration {
    secret_token = "${data.aws_ssm_parameter.webhook_secret.value}"
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "bar" {
  repository = "${data.github_repository.example.name}"

  name = "web"

  configuration {
    url          = "${aws_codepipeline_webhook.bar.url}"
    content_type = "application/json"
    insecure_ssl = false
    secret       = "${data.aws_ssm_parameter.webhook_secret.value}"
  }

  events = ["push", "pull_request"]
}
