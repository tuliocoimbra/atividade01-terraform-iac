# Atividade 1 - Provisionamento de Infraestrutura Web na AWS com Terraform

**Aluno:** Tulio Augusto Coimbra dos Santos
**Turma:** Pos em DevOps 2025.2 - CESAR
**Disciplina:** Fundamentos de Infraestrutura como Codigo

---

## Descricao

Este projeto provisiona na AWS a infraestrutura minima para hospedar uma pagina web simples, utilizando Terraform com:

- VPC com subnet publica, Internet Gateway e Route Table
- Security Group com HTTP aberto (porta 80) e SSH restrito ao IP do aluno
- Instancia EC2 (Amazon Linux 2023, buscada dinamicamente via `data "aws_ami"`)
- User data que instala e inicia o Apache (httpd) com pagina HTML personalizada
- **Backend remoto** (S3) para armazenamento do state
- **Workspaces** (dev e prod) para gerenciar multiplos ambientes com o mesmo codigo
- **Modulo proprio** (`modules/servidor-web`) encapsulando o Security Group e a instancia EC2

---

## Estrutura do projeto

```
.
├── main.tf                     # Recursos principais (VPC, subnet, IGW, route table, modulo)
├── variables.tf                # Variaveis com tipos explicitos e defaults
├── outputs.tf                  # Outputs (IP publico, DNS, etc.)
├── terraform.tfvars.example    # Exemplo de variaveis sensiveis (nao commitar o .tfvars real)
├── .gitignore                  # Ignora .terraform/, *.tfstate*, *.tfvars
├── .terraform.lock.hcl         # Lock de providers (versionado)
├── README.md                   # Este arquivo
└── modules/
    └── servidor-web/
        ├── main.tf             # Security Group + EC2
        ├── variables.tf        # Variaveis do modulo
        └── outputs.tf          # Outputs do modulo
```

---

## Pre-requisitos

1. **Terraform** >= 1.5.0 instalado
2. **AWS CLI** configurado (`aws configure`) com um usuario IAM com permissoes adequadas
3. **Bucket S3** criado manualmente para o backend remoto (veja secao abaixo)

---

## Backend S3 (state remoto)

O bucket S3 usado como backend remoto e:

```
tulio-terraform-state-iac
```

Ele deve ser criado **uma unica vez**, manualmente, antes do `terraform init`:

```bash
aws s3api create-bucket \
  --bucket tulio-terraform-state-iac \
  --region us-east-1
```

> **Nota:** Nenhuma credencial e armazenada neste repositorio. O Terraform usa as credenciais configuradas via `aws configure`.

---

## Como executar

### 1. Clone o repositorio

```bash
git clone git@github.com:tuliocoimbra/atividade01-terraform-iac.git
cd atividade01-terraform-iac
```

### 2. Configure suas variaveis

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edite o `terraform.tfvars` e preencha seu IP publico:

```hcl
meu_ip = "SEU.IP.PUBLICO/32"
```

> Para descobrir seu IP publico: `curl -s ifconfig.me`

### 3. Inicialize o Terraform

```bash
terraform init
```

### 4. Crie e selecione os workspaces

```bash
terraform workspace new dev
terraform workspace new prod
```

### 5. Deploy no workspace dev

```bash
terraform workspace select dev
terraform plan
terraform apply
```

### 6. Deploy no workspace prod

```bash
terraform workspace select prod
terraform plan
terraform apply
```

### 7. Verifique a pagina web

Acesse no navegador o IP publico retornado no output:

```
http://<ip_publico>
```

### 8. Destrua os recursos (obrigatorio ao final)

```bash
terraform workspace select dev
terraform destroy

terraform workspace select prod
terraform destroy
```

---

## Workspaces utilizados

| Workspace | Tipo de instancia | Finalidade           |
|-----------|-------------------|----------------------|
| dev       | t2.micro          | Ambiente de dev/test |
| prod      | t3.micro          | Ambiente de producao |

As evidencias de `terraform apply` e `terraform destroy` foram geradas em **ambos os workspaces** (dev e prod).

---

## Variacoes por workspace

O tipo de instancia varia automaticamente conforme o workspace ativo:

- `dev` -> `t2.micro`
- `prod` -> `t3.micro`

As tags de todos os recursos incluem `Ambiente = terraform.workspace`, refletindo o ambiente atual.

---

## Seguranca

- A porta SSH (22) e restrita exclusivamente ao IP do aluno (`/32`)
- A porta HTTP (80) e aberta para acesso publico (pagina web)
- Nenhuma credencial AWS esta commitada neste repositorio
- O arquivo `terraform.tfvars` (com dados sensiveis) esta no `.gitignore`

---

## Validacao

```bash
terraform fmt -check    # Verifica formatacao
terraform validate      # Valida configuracao
```
