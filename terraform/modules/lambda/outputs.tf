output "lambda_arn" {
  value = aws_lambda_function.agent_handler_kb.arn
  description = "Lambda function arn"
}

output "lambda_function_name" {
  value = aws_lambda_function.agent_handler_kb.function_name
  description = "Lambda function name"
}

output "lambda_iam_role_arn" {
  value = aws_iam_role.lambda_role.arn
  description = "Lambda IAM role arn"
}

output "lambda_iam_role_name" {
  value = aws_iam_role.lambda_role.name
  description = "Lambda IAM role name"
}