output "github_actions_role_arn" {
  description = "The ARN of the IAM role assumed by GitHub Actions for deployment"
  value = aws_iam_role.github_actions.arn
}