# iac-public

Códigos para realizar o deployment de componentes necessários para uso da infraestrutura do Escritório de Dados da Prefeitura do Rio de Janeiro.

## O que você encontrará aqui

### `gke-autopilot/`

Faz o deploy de um Cluster Kubernetes na Google Cloud Platform (GCP) com o modo Autopilot habilitado.

**Requisitos:**

- Um projeto Google Cloud Platform (GCP)
- Kubernetes Engine API habilitada. [Link](https://console.cloud.google.com/marketplace/product/google/container.googleapis.com)
- Um bucket no Google Cloud Storage (GCS) com nome arbitrário (sugere-se, para fins de organização, que tenha o prefixo `terraform-data`) [Tutorial](https://cloud.google.com/storage/docs/creating-buckets)
- Uma conta de serviço com papel de "Editor" (sugere-se, para fins de organização, que tenha o nome `terraform`) [Tutorial](https://cloud.google.com/iam/docs/creating-managing-service-accounts)

**Passo a passo:**

- Gerar uma chave JSON para a conta de serviço e armazená-la em seu computador, de maneira segura.
- Configurar a variável de ambiente com a chave JSON da conta de serviço:

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
```

- No diretório `gke-autopilot/`, executar o comando:

```
terraform init
```

- Em seguida, executar o comando:

```
terraform apply
```

- Ele irá solicitar ao usuário que digite o nome do bucket criado para armazenamento dos dados do Terraform, além do nome do projeto no GCP.

- Aguarde o processo terminar.
