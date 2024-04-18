# AWS CodePipeline created using Terraform
This infrastructure is used for my final diploma project and provides all the resources needed for a pipeline.

**Files:**
1. main.tf is used to create the pipeline and IAM roles for it. All the stages are put together.
2. codebuild.tf is used to provision the build stage and the IAM roles for it. The source is AWS CodeCommit.
3. codedeploy.tf is used to provision the deploy stage and the IAM roles for it. The deployment is done by an EC2 instance.
4. install-code-deploy-agent.sh is a script used to install the agent for CodeDeploy on EC2 instance.

# Installation
 - terraform init
 - terraform plan -out plan.out
 - terraform apply plan.out --auto-approve
