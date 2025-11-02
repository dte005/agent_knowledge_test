variable "agent_name" {
  type = string
  description = "Agent name on aws"
  default = "agent_terraform_test"
}

variable "foundation_model_arn" {
  type = string
  description = "Arn from foundation model resource"
}

variable "agent_instructions" {
  type = string
  description = "Instructions to agent"
}