Projeto Agente RAG (Recuperação Aumentada por Geração)
Este repositório contém a infraestrutura como código (IaC) para implantar uma solução completa de RAG (Retrieval-Augmented Generation) na AWS. O projeto usa o Terraform para provisionar e conectar um Agente do Amazon Bedrock a uma Base de Conhecimento (Knowledge Base) vetorizada, permitindo que o Agente responda perguntas usando seus documentos privados.

🚀 Principais Componentes e Arquitetura
Este projeto provisiona um ecossistema de serviços da AWS, onde o "módulo raiz" (ex: a pasta dev/) atua como o "maestro", instanciando e "costurando" os seguintes módulos especializados:

Agente (Agent): Um Agente do Amazon Bedrock (module "agent_orchestrator")  que atua como o cérebro principal, orquestrando a conversa e decidindo quando consultar a base de conhecimento.

Modelo de Fundação (FM): O Agente e o Knowledge Base utilizam Modelos de Fundação (Foundation Models) do Bedrock, gerenciados de forma centralizada pelo module "bedrock_inference_profile" (ex: Claude Sonnet 4.0) .

Base de Conhecimento (KB): Um Knowledge Base do Amazon Bedrock (module "knowledge_base") . Este módulo cria automaticamente:




Um banco de dados OpenSearch Serverless para armazenar os vetores.

As permissões de IAM necessárias para o Bedrock acessar o OpenSearch e o S3.

O Data Source que conecta o KB ao bucket S3 onde os documentos são armazenados.

Funções Lambda (Lambda): O projeto utiliza Lambdas para duas funções principais:

Sincronização de Dados: O module "bedrock_sync_datasource"  cria uma API Gateway e uma função Lambda que expõem um endpoint de API. Chamar este endpoint (ex: POST /sync/all) inicia o trabalho de ingestão de dados do Knowledge Base.

(Opcional) Uma Lambda de transformação pode ser configurada no Knowledge Base para pré-processar documentos antes da vetorização .


Fluxo de Dados da Arquitetura

Uma aplicação externa (ex: um frontend) assume o "Crachá de Acesso" (aws_iam_role "app_role") .

A aplicação envia o prompt do usuário para o endpoint do Agente Bedrock (bedrock:InvokeAgent) .

O Agente Orquestrador (module "agent_orchestrator")  recebe o prompt.

O Agente determina que precisa consultar seus documentos e invoca o Knowledge Base (module "knowledge_base")  (a parte de RAG).




O Knowledge Base converte a consulta em um vetor, busca documentos semanticamente similares no OpenSearch Serverless e retorna os trechos de texto relevantes.

O Agente pega os trechos de texto (o contexto) e o prompt original, os envia ao Modelo de Fundação (ex: Claude 4.0)  e gera uma resposta final e fundamentada.

Fluxo de Sincronização e Descoberta

Este projeto também inclui um sofisticado sistema de descoberta de serviços e sincronização com um backend externo (ex: MongoDB).

Descoberta de Serviço: O module "parameter_store"  é usado como um "Catálogo de Endereços". Ele salva os ARNs e IDs de todos os recursos criados (Agente, KB, S3)  em um caminho centralizado no AWS Parameter Store. O parâmetro bedrock_agent/orchestrator/details  é o endpoint centralizado para o frontend ler.





Gatilho de Sincronização: Um null_resource "mongodb_parameter_sync_trigger" monitora mudanças nos arquivos de configuração do Agente e do KB . Se qualquer um mudar, ele dispara um provisioner "local-exec" que executa um curl  para "cutucar" sua API de backend (definida em variables.tf), notificando-a para se atualizar lendo os novos valores do Parameter Store.


Pré-requisitos
Terraform v1.5.6 ou mais recente .

Credenciais da AWS configuradas (ex: via AWS CLI).

Um backend Terraform configurado (recomendado).

⚙️ Configuração do Ambiente
Clonar o Repositório:

Bash
git clone <url-do-seu-repositorio>
cd <repositorio>/environments/dev
(Recomendado) Configurar Backend Remoto: Crie um arquivo backend.tf (ou adicione ao provider.tf) para configurar o state remoto. O projeto, como escrito, usará o state local por padrão .

Exemplo de backend.tf para S3:

Terraform
terraform {
backend "s3" {
bucket         = "nome-do-seu-bucket-de-estado"
key            = "rag-agent/dev/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-state-lock"
}
}
Criar seu Arquivo de Variáveis: Copie o arquivo de exemplo e preencha com seus valores.

Bash
cp terraform.tfvars.example terraform.tfvars
Editar terraform.tfvars: Você deve preencher as variáveis marcadas em terraform.tfvars.example , especialmente:

tag_*: Todas as tags de governança (centro de custo, proprietário, etc.) .

app_id: O ID da sua aplicação para a API de sincronização .



token_dev: O token Bearer para autenticar com sua API de backend (MongoDB).


🚀 Implantação (Uso)
Este projeto é projetado para ser implantado a partir da pasta de ambiente (ex: environments/dev).

Inicializar o Terraform: (Este comando baixa os providers, incluindo o aws  e os providers internos dos módulos, como opensearch).

Bash
terraform init
Validar e Planejar:

Bash
terraform validate
terraform plan
Aplicar a Configuração: (Isso criará todos os recursos descritos na arquitetura).

Bash
terraform apply
Após a conclusão, o terraform apply executará o gatilho null_resource , que fará a primeira chamada de curl  para notificar seu backend.


📦 Saídas Principais (Outputs)
Após a implantação, a pasta de ambiente (dev) fornecerá saídas (outputs). Os mais importantes são:

app_role_arn : O ARN do "Crachá de Acesso" (IAM Role) que sua aplicação de frontend deve "assumir" para poder interagir com o Agente e o S3.

application_s3_bucket_name : O nome do bucket S3 onde você deve carregar seus documentos para o Knowledge Base.

parameter_store_paths : O caminho raiz no AWS Parameter Store (ex: /seu-projeto/dev/). Você (ou seu frontend) pode consultar este caminho para "descobrir" os ARNs e IDs de todos os outros recursos (Agente, KB, etc.).

bedrock_sync_api_url : O endpoint da API Gateway que você pode chamar para disparar manualmente uma ressincronização do Knowledge Base.