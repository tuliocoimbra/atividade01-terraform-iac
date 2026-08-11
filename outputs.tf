output "ip_publico" {
  description = "IP público da instância EC2"
  value       = module.servidor_web.ip_publico
}

output "dns_publico" {
  description = "DNS público da instância EC2"
  value       = module.servidor_web.dns_publico
}

output "id_instancia" {
  description = "ID da instância EC2"
  value       = module.servidor_web.id_instancia
}

output "ami_utilizada" {
  description = "ID da AMI Amazon Linux 2023 selecionada dinamicamente"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "workspace_atual" {
  description = "Workspace Terraform ativo no momento do apply"
  value       = terraform.workspace
}
