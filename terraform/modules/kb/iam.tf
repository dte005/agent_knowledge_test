terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }
}
# Perfil assumido pelo kb NECESSÁRIO
data "aws_iam_policy_document" "kb_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type  = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kb_role" {
  name = "${var.kb_name}-role"
  assume_role_policy = data.aws_iam_policy_document.kb_assume_role.json
}

#Permissao que a kb precisa para funcionar
data "aws_iam_policy_document" "kb_permissions" {
  #persmissao para ler arquivos do s3 e listar buckets
  statement {
    sid = "S3Access"
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.kb_source.arn,"${aws_s3_bucket.kb_source.arn}/*"]
  }

  #permissao para chamar o embedding model TITAN
  statement {
    sid = "EmbedingModelAccess"
    actions = ["bedrock:InvokeModel"]
    resources = [local.embedding_model_arn]
  }

  #permissao para escrever no opensearch
  statement {
    sid = "OSSSAccess"
    actions = ["aoss:APIAccessAll"]
    resources = [aws_opensearchserverless_collection.kb_vector_store.arn]
  }
}

resource "aws_iam_policy" "kb_policy" {
  name = "${var.kb_name}-policy"
  policy = data.aws_iam_policy_document.kb_permissions.json
}

resource "aws_iam_role_policy_attachment" "kb_policy_attach" {
  role = aws_iam_role.kb_role.name
  policy_arn = aws_iam_policy.kb_policy.arn
}