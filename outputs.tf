output "github_actions_role_arn" {
  value = module.iam_cicd.github_actions_role_arn
}

output "db_endpoint" {
  value = module.database.db_endpoint
}