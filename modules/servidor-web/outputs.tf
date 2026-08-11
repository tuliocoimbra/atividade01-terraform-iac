output "ip_publico" {
  description = "IP publico da instancia EC2"
  value       = aws_instance.servidor_web.public_ip
}

output "dns_publico" {
  description = "DNS publico da instancia EC2"
  value       = aws_instance.servidor_web.public_dns
}

output "id_instancia" {
  description = "ID da instancia EC2 criada"
  value       = aws_instance.servidor_web.id
}

output "id_security_group" {
  description = "ID do Security Group criado"
  value       = aws_security_group.servidor_web.id
}
