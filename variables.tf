variable "regiao" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block da subnet pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "porta_http" {
  description = "Porta HTTP para acesso à página web"
  type        = number
  default     = 80
}

variable "meu_ip" {
  description = "Seu IP público para restrição de acesso SSH (formato: x.x.x.x/32)"
  type        = string
}
