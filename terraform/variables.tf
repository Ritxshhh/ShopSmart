variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "image_tag" {
  description = "Docker image tag — set to the commit SHA by the CI pipeline"
  type        = string
  default     = "latest"
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS Fargate tasks"
  type        = list(string)
  default     = ["subnet-0ffe187fbf6edaaae"]
}

variable "security_group_id" {
  description = "Security group ID attached to ECS Fargate tasks"
  type        = string
  default     = "sg-025eeda8f797386f7"
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role. Leave empty to auto-detect LabRole (AWS Academy)."
  type        = string
  default     = ""
}
