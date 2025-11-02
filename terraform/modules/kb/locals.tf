locals {
  common_tags =  {
    Project = "agent-terraform-test"
    Terraform = true
  }
  embedding_model_arn = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v1"
}