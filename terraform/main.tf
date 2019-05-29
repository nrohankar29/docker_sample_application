provider "aws" {
  version = "~> 2.0"
  region = "${var.aws_region}"
}

resource "aws_iam_role" "codeBuildServiceRole" {
  name = "${var.service_role}"

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

resource "aws_iam_role_policy" "codeBuildServiceRolePolicy" {
  role = "${aws_iam_role.codeBuildServiceRole.name}"

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
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "cloudtrail:LookupEvents"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "dockerSampleApplication" {
  name          = "${var.codebuild_project_name}"
  description   = "test_codebuild_project"
  build_timeout = "60"
  service_role  = "${aws_iam_role.codeBuildServiceRole.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      "name"  = "AWS_DEFAULT_REGION"
      "value" = "${var.aws_region}"
    }

    environment_variable {
      "name"  = "AWS_ACCOUNT_ID"
      "value" = "${var.aws_account_code}"
    }

    environment_variable {
      "name"  = "IMAGE_REPO_NAME"
      "value" = "${var.ecr_image_repo_name}"
    }

    environment_variable {
      "name"  = "IMAGE_TAG"
      "value" = "latest"
    }

  }

  source {
    type                = "GITHUB"
    location            = "https://github.com/nrohankar29/docker_sample_application.git"
    git_clone_depth     = 1
    report_build_status = true
  }

  tags = {
    "Environment" = "Test"
  }
}
