data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "kb_source" {
  bucket = "${var.kb_name}-source-${data.aws_caller_identity.current.account_id}"
  tags = local.common_tags
}

resource "aws_opensearchserverless_collection" "kb_vector_store" {
  name = "${var.kb_name}-collection"
  type = "VECTORSEARCH"
  depends_on = []
  tags = local.common_tags
}

resource "aws_bedrockagent_knowledge_base" "this" {
  name     = var.kb_name
  role_arn = aws_iam_role.kb_role.arn
  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = local.embedding_model_arn
    }
  }
  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.kb_vector_store.arn
      vector_index_name = "bedrock-vector-index"
      #serve como um mapa que diz ao bedrock como organizar as informações
      #dentro do bd vetorial
      field_mapping {
        text_field = "text"
        metadata_field = "metadata"
      }
    }
  }
  tags = merge(local.common_tags, {"Location": "aws_bedrockagent_knowledge_base"})

  depends_on = [
    aws_opensearchserverless_collection.kb_vector_store
  ]
}

resource "aws_bedrockagent_data_source" "s3_data_source" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id
  name              = "${var.kb_name}-data-source"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.kb_source.arn
    }
  }
}