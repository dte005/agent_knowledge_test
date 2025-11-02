output "agent_id" {
  value = aws_bedrockagent_agent.this.id
  description = "Agent bedrock id"
}

output "agent_arn" {
  value = aws_bedrockagent_agent.this.agent_arn
  description = "Agent bedrock arn"
}

output "agent_iam_role_arn" {
  value = aws_iam_role.bedrock_agent_role.arn
  description = "Agent bedrock IAM role arn"
}

output "agent_iam_role_name" {
  value = aws_iam_role.bedrock_agent_role.name
  description = "Agent bedrock IAM role name"
}