resource "aws_bedrockagent_agent" "this" {
  description = "Main agent of structure"
  agent_name = var.agent_name
  foundation_model = var.foundation_model_arn
  agent_resource_role_arn = aws_iam_role.bedrock_agent_role.arn
  instruction = var.agent_instructions
  tags = local.common_tags
  # guardrail_configuration {
  #   guardrail_identifier = ""
  #   guardrail_version = ""
  # }
}