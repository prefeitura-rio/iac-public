# iac-public

Códigos para realizar o deployment de componentes necessários para uso da infraestrutura do Escritório de Dados da Prefeitura do Rio de Janeiro.

## O que você encontrará aqui

### `gke/`

Faz o deploy de um Cluster Kubernetes na Google Cloud Platform (GCP).

**Dependências**:

- N/A

**Requisitos:**

- Um projeto Google Cloud Platform (GCP)
- Kubernetes Engine API habilitada. ([Link](https://console.cloud.google.com/marketplace/product/google/container.googleapis.com))
- Um bucket no Google Cloud Storage (GCS) com nome arbitrário (sugere-se, para fins de organização, que tenha o prefixo `terraform-data`) ([Tutorial](https://cloud.google.com/storage/docs/creating-buckets))
- Uma conta de serviço com papel de "Editor" (sugere-se, para fins de organização, que tenha o nome `terraform`) ([Tutorial](https://cloud.google.com/iam/docs/creating-managing-service-accounts))

**Passo a passo:**

- Gerar uma chave JSON para a conta de serviço e armazená-la em seu computador, de maneira segura.
- Configurar um arquivo de variáveis de ambiente `.env` conforme modelo abaixo:

```
GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
TF_VAR_bucket_name=terraform-bucket-name
TF_VAR_project_id=your-project-id
```

- Exportar as variáveis de ambiente:

```
source .env
```

- No diretório `gke/`, executar o comando:

```
terraform init
```

- (Opcional) Você pode navegar pelos arquivos, principalmente o `variables.tf` e alterá-los para modificar o que desejar.

- Em seguida, executar o comando:

```
terraform apply
```

- Aguarde o processo terminar.

### `prefect-agent/`

Faz o deploy de um Kubernetes Agent do Prefect para uso com a instância master, hospedada no projeto do Escritório de Dados.

**Dependências**:

- gke (ou algum cluster Kubernetes)

**Requisitos:**

- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Helm](https://helm.sh/docs/intro/install/)
- Acesso configurado ao cluster no GKE via kubectl ([Tutorial](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl))
- Uma conta de serviço com papel de "Editor" (sugere-se, para fins de organização, que tenha o nome `prefect-agent`) ([Tutorial](https://cloud.google.com/iam/docs/creating-managing-service-accounts))
- Estar inserido na rede Tailnet ([Tutorial](https://library-emd.herokuapp.com/infraestrutura/como-acessar-a-ui-do-prefect)). Não é necessário seguir o tutorial até o final, somente até o fim da seção "Preparo inicial"
- Uma chave de autenticação para o Tailscale ([Tutorial](https://tailscale.com/kb/1085/auth-keys/))

**Antes de iniciar**:

- Fornecer ao escritório de dados um arquivo kubeconfig que permita acesso ao cluster Kubernetes onde será hospedado o Prefect Agent, solicitando que ele seja adicionado à Service Mesh.

- Aguardar a confirmação de que o cluster foi adicionado à Service Mesh.

**Passo a passo:**

- Gerar uma chave JSON para a conta de serviço e armazená-la em seu computador, de maneira segura.

- Crie um namespace para o Prefect Agent:

```
kubectl create ns prefect
```

- Adicione o label do Istio no namespace do Prefect Agent

```
kubectl annotate namespace prefect linkerd.io/inject=enabled
```

- Adicione um secret com a sua chave JSON para a conta de serviço:

```
kubectl create secret generic gcp-sa --from-file=creds.json=/path/to/your/key.json -n prefect
```

- Modifique o arquivo `prefect-agent/basedosdados/config.toml` trocando `your-project-name` pelo nome do projeto no GCP.

- Altere o arquivo `prefect-agent/manifests/secrets.yaml` da seguinte forma:

  - `BASEDOSDADOS_CONFIG` deve corresponder ao resultado do comando `cat prefect-agent/basedosdados/config.toml | base64 -w 0`
  - `BASEDOSDADOS_CREDENTIALS_PROD` e `BASEDOSDADOS_CREDENTIALS_DEV` devem corresponder ao resultado do comando `cat /path/to/your/key.json | base64 -w 0`

- Crie o secret para uso do basedosdados:

```
kubectl apply -f path/to/secrets.yaml -n prefect
```

- Adicione o repositório da Prefeitura do Rio de Janeiro no Helm:

```
helm repo add prefeitura-rio https://prefeitura-rio.github.io/charts
helm repo update
```

- Leia os comentários do arquivo `prefect-agent/values.yaml` e faça as modificações necessárias para seu caso de uso. Atente-se aos comentários "FILL: ...", eles demarcam os parâmetros que devem ser obrigatoriamente alterados. São eles:

  - `agent.prefectLabels`

- Instale o Prefect Agent:

```
helm upgrade --install prefect-agent prefeitura-rio/prefect-agent --namespace prefect -f prefect-agent/values.yaml
```
