terraform-codepipeline-example
==============================

From terraform doc: https://www.terraform.io/docs/providers/aws/r/codepipeline.html


Create a AWS SSM Parameter Store

    aws ssm put-parameter --name "/terraform-codepipeline-example/webhook_secret" --type String  --value "******"

Check 

     aws ssm get-parameter  --name "/terraform-codepipeline-example/webhook_secret"  

Plan/apply/destroy

    terraform plan -var-file="default.tfvars"
