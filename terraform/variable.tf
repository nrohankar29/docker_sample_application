variable "aws_region" {
  default = "us-east-1"
}

variable "service_role" {
  default = "codeBuildServiceRole"
}

variable "codebuild_project_name" {
  default = "docker-sample-application"
}

variable "aws_account_code" {
  default = "111111111111"
}

variable "ecr_image_repo_name" {
  default = "test_repo"
}
