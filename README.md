# AWS CodePipeline created using Terraform 
This infrastructure is used for my final diploma project and provides all the resources needed for a pipeline in AWS.

**Files:**
1. [`main.tf`](https://github.com/Sebastianutcn/pipeline-terraform/blob/main/main.tf) is used to create the pipeline and IAM roles for it. All the stages are put together.
2. [`codebuild.tf`](https://github.com/Sebastianutcn/pipeline-terraform/blob/main/codebuild.tf) is used to provision the build stage and the IAM roles for it. The source is AWS CodeCommit.
3. [`codedeploy.tf`](https://github.com/Sebastianutcn/pipeline-terraform/blob/main/codedeploy.tf) is used to provision the deploy stage and the IAM roles for it. The deployment is done by an EC2 instance.
4. [`install-code-deploy-agent.sh`](https://github.com/Sebastianutcn/pipeline-terraform/blob/main/install-code-deploy-agent.sh.tf) is a script used to install the agent for CodeDeploy on EC2 instance.

## Installation
- Terraform command to initialize the project
```
terraform init
```
* Terraform command to plan the changes and to check again the resources that were added, changed or deleted
```
terraform plan -out plan.out
```
- Terraform command to apply the changes
```
terraform apply plan.out --auto-approve
```
