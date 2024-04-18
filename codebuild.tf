data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "mytodoapp" {
  bucket = "codebuild-mytodoapp"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.mytodoapp.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.mytodoapp]
}

resource "aws_s3_bucket_ownership_controls" "mytodoapp" {
  bucket = aws_s3_bucket.mytodoapp.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# adaugat fara apply
resource "aws_s3_bucket_versioning" "mytodoapp" {
  bucket = aws_s3_bucket.mytodoapp.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_ecr_repository" "mytodoapp-ecr" {
  name                 = "mytodoapp-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# resource "aws_ssm_parameter" "mytodoapp" {
#   name        = "/codeBuild/dockerPassword"
#   description = "The Dockerhub password"
#   type        = "SecureString"
#   value       = var.dockerhub_password
# }

resource "aws_iam_role" "codebuild-role" {
  name = "codebuild-role-mytodoapp"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild-policy" {
  role = aws_iam_role.codebuild-role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.mytodoapp.arn}",
        "${aws_s3_bucket.mytodoapp.arn}/*"
      ]
    },
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "ssm:GetParameters"
      ],
      "Resource" : "*",
      "Effect" : "Allow"
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "mytodoapp" {
  name          = "mytodoapp"
  description   = "mytodoapp node.js app build project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild-role.arn

  artifacts {
    type     = "S3"
    location = aws_s3_bucket.mytodoapp.bucket
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.mytodoapp.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.mytodoapp-ecr.name
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.mytodoapp.id}/build-log"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/mytodoapp-repo"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  tags = {
    Environment = "Test"
  }
}