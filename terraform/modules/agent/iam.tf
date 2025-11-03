#agent resource role
#lambda execution role

### ROLE QUE O AGENTE IRÁ ASSUMIR
resource "aws_iam_role" "bedrock_agent_role" {
  name = "BedrockAgentExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "bedrock.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = merge(local.common_tags, {"Location": "bedrock_agent_role"})
}