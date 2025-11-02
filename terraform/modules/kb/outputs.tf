output "kb_role_arn" {
  value = aws_iam_role.kb_role.arn
  description = "Knowledge base role arn"
}
output "kb_role_name" {
  value = aws_iam_role.kb_role.name
  description = "Knowledge base role name"
}
output "knowledge_base_arn" {
  value = aws_bedrockagent_knowledge_base.this.arn
  description = "Knowledge base arn"
}

output "opensearch_collection_arn" {
  value = aws_opensearchserverless_collection.kb_vector_store.arn
  description = "Opensearch vector collection arn"
}