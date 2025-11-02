variable "lambda_runtime" {
  default = "nodejs20.x"
}

variable "lambda_function_name" {
  default = "lambdaHandlerKb"
}

variable "agent_name" {
  default = "agentKnowledgeTest"
}

variable "foundation_model_arn" {
  default = "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
}

variable "knowledge_base_name" {
  default = "kbbasetest"
}