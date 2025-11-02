data "archive_file" "lambda_empty_template" {
  type = "zip"
  output_path = "${path.module}/template_lambda.zip"
  source {
    content  = "function handler(event, context){ return {'statusCode': 200, body: JSON.stringify('template/cicd')}}"
    filename = "${var.lambda_function_name}.js"
  }
}

resource "aws_lambda_function" "agent_handler_kb" {
  function_name = var.lambda_function_name
  handler = "${var.lambda_function_name}.handler"
  #nodejs20.x
  runtime = var.lambda_runtime
  role = aws_iam_role.lambda_role.arn
  filename = data.archive_file.lambda_empty_template.output_path
  source_code_hash = data.archive_file.lambda_empty_template.output_base64sha256
  # Isto diz ao Terraform:
  # "Você é responsável por criar este Lambda, mas DEPOIS disso,
  # NUNCA mais tente gerenciar o código fonte."
  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash
    ]
  }
  tags = local.common_tags
  depends_on = [
    data.archive_file.lambda_empty_template
  ]
}