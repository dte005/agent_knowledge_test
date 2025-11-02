### POLÍTICA QUE O LAMBDA IRÁ ASSUMIR
resource "aws_iam_policy" "lambda_policy" {
  name = "${var.lambda_function_name}-policy"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "bedrock:Retrieve",
            "bedrock:RetrieveAndGenerate"
          ],
          Resource = module.kb.knowledge_base_arn
        }
      ]
    }
  )
  depends_on = [module.kb]
}

## JUNÇÃO DE POLÍTICA COM ROLE
resource "aws_iam_role_policy_attachment" "lambda_execution_attach" {
  role       = module.lambda.lambda_iam_role_name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "lambda_execution_logs" {
  role       = module.lambda.lambda_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

### POLÍTICA DO QUE O AGENTE PODE FAZER
resource "aws_iam_policy" "bedrock_agent_policy" {
  name        = "BedrockAgentPolicy"
  description = "Permite que o agente invoque FMs e a função lambda do action Group"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        #Permite a invocação do foundation model
        Effect   = "Allow",
        Action   = "bedrock:InvokeModel",
        Resource = var.foundation_model_arn
      },
      {
        #Permite a invocação do lambda
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = module.lambda.lambda_arn
      }
    ]
  })
}

### LIGAÇÃO ENTRE ROLE E POLICY
resource "aws_iam_role_policy_attachment" "agent_policy_attach" {
  policy_arn = aws_iam_policy.bedrock_agent_policy.arn
  role       = module.agent.agent_iam_role_name
}

## Políticas de acesso ao opensearch
## Define quem pode acessar o quê. KB e Lambda
resource "aws_opensearchserverless_access_policy" "opensearch_data_access" {
  name = "${var.knowledge_base_name}-data-access"
  type = "data"
  policy = jsonencode([
    {
      #Regra que permite o perfil da KB gerencie os indices
      Rules = [
        {
          ResourceType = "index",
          Resource     = ["index/${var.knowledge_base_name}/*"]
          Permission   = ["aoss:*"]
        }
      ],
      Principal = [module.kb.kb_role_arn]
    },
    {
      #Regra que permite o lambda consultar indices
      Rules = [
        {
          ResourceType = "index",
          Resource     = ["index/${var.knowledge_base_name}/*"]
          Permission   = ["aoss:ReadDocument"]
        }
      ],
      Principal = [module.lambda.lambda_iam_role_arn]
    }
  ])
  depends_on = [module.lambda]
}