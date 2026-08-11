variable "nome_servidor" {
  description = "Nome base para os recursos do servidor web"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o servidor sera criado"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet onde a instancia sera lancada"
  type        = string
}

variable "tipo_instancia" {
  description = "Tipo da instancia EC2 (ex: t2.micro, t3.micro)"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID da AMI a ser usada na instancia"
  type        = string
}

variable "porta_http" {
  description = "Porta HTTP para acesso a pagina web"
  type        = number
  default     = 80
}

variable "porta_ssh" {
  description = "Porta SSH para acesso remoto"
  type        = number
  default     = 22
}

variable "meu_ip" {
  description = "IP publico do aluno para restricao de SSH (formato x.x.x.x/32)"
  type        = string
}

variable "user_data" {
  description = "Script de inicializacao da instancia (user_data)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags a serem aplicadas em todos os recursos"
  type        = map(string)
  default     = {}
}
