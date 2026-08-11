# =============================================
# Atividade 1 - Terraform
# Aluno: Tulio Augusto Coimbra dos Santos
# Turma: Pos em DevOps 2025.2 - CESAR
# =============================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend S3 para state remoto
  backend "s3" {
    bucket       = "tulio-terraform-state-iac"
    key          = "atividade01/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.regiao

  default_tags {
    tags = {
      Curso    = "Fundamentos de IaC - CESAR"
      Ambiente = terraform.workspace
      Aluno    = "Tulio Augusto Coimbra dos Santos"
    }
  }
}

# =============================================
# Busca dinamica da AMI Amazon Linux 2023
# =============================================
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# =============================================
# Definicao do tipo de instancia por workspace
# =============================================
locals {
  tipo_instancia = terraform.workspace == "prod" ? "t3.micro" : "t2.micro"

  tags_comuns = {
    Name     = "servidor-web-${terraform.workspace}"
    Curso    = "Fundamentos de IaC - CESAR"
    Ambiente = terraform.workspace
  }

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd
    cat <<HTML > /var/www/html/index.html
    <html>
    <body>
    <h1>Atividade 1 - Terraform</h1>
    <p>Aluno: Tulio Augusto Coimbra dos Santos</p>
    <p>Turma: Pos em DevOps 2025.2 - CESAR</p>
    <p>Ambiente: ${terraform.workspace}</p>
    </body>
    </html>
    HTML
  EOF
}

# =============================================
# Rede: VPC, Subnet, Internet Gateway, Route Table
# =============================================
resource "aws_vpc" "principal" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags_comuns, {
    Name = "vpc-atividade1-${terraform.workspace}"
  })
}

resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.regiao}a"

  tags = merge(local.tags_comuns, {
    Name = "subnet-publica-${terraform.workspace}"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.principal.id

  tags = merge(local.tags_comuns, {
    Name = "igw-atividade1-${terraform.workspace}"
  })
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.principal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.tags_comuns, {
    Name = "rt-publica-${terraform.workspace}"
  })
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}

# =============================================
# Modulo servidor-web (Security Group + EC2)
# =============================================
module "servidor_web" {
  source = "./modules/servidor-web"

  nome_servidor  = "servidor-web-${terraform.workspace}"
  vpc_id         = aws_vpc.principal.id
  subnet_id      = aws_subnet.publica.id
  tipo_instancia = local.tipo_instancia
  ami_id         = data.aws_ami.amazon_linux_2023.id
  porta_http     = var.porta_http
  porta_ssh      = 22
  meu_ip         = var.meu_ip
  user_data      = local.user_data
  tags           = local.tags_comuns
}
