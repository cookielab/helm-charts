variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "github_repo" {
  description = "GitHub repository in format owner/repo"
  type        = string
  default     = "cookielab/helm-complex-chart"
}

variable "github_branch" {
  description = "GitHub branch that can assume the role"
  type        = string
  default     = "main"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Helm repository"
  type        = string
  default     = "clb-dev-helm"
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  type        = string
} 
