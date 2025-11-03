# ===================================================================
# Invocando o Módulos
# ===================================================================

module "kb" {
  source  = "./modules/kb"
  kb_name = var.knowledge_base_name
  depends_on = [
    aws_iam_policy.lambda_policy,
    aws_opensearchserverless_security_policy.opensearch_encryption_policy
  ]
}

module "lambda" {
  source               = "./modules/lambda"
  lambda_runtime       = var.lambda_runtime
  lambda_function_name = var.lambda_function_name
}

module "agent" {
  source               = "./modules/agent"
  agent_name           = var.agent_name
  foundation_model_arn = var.foundation_model_arn
  agent_instructions   = file("${path.module}/instructions.txt")
}

#Action group que faz a junção entre o agent e o lambda
resource "aws_bedrockagent_agent_action_group" "agent_action_group" {
  action_group_name = "ActionGroupInvokeLambdaForKnowledgeBase"
  agent_id          = module.agent.agent_id
  agent_version     = "DRAFT"
  description       = "Action group to invoke lambda"
  action_group_executor {
    lambda = module.lambda.lambda_arn
  }
  #Schema da api
  #Regra para o agente LLM saber usar seu lambda
  function_schema {
    member_functions {
      functions {
        name        = var.lambda_function_name
        description = "Lambda function to get KB data"
        #TODO Next version must accept parameters from input
        parameters {
          map_block_key = "req_user"
          type          = "string"
          required      = true
          description   = "Request from user"
        }
      }
    }
  }
  depends_on = [
    module.agent, module.lambda
  ]
}
