# =============================================
# Modulo: servidor-web
# Cria um Security Group e uma instancia EC2
# para servir uma pagina web simples.
# =============================================

resource "aws_security_group" "servidor_web" {
  name        = "${var.nome_servidor}-sg"
  description = "Security Group do servidor web - permite HTTP e SSH restrito"
  vpc_id      = var.vpc_id

  # Regra de entrada: HTTP aberto para todos (pagina publica)
  ingress {
    description = "HTTP"
    from_port   = var.porta_http
    to_port     = var.porta_http
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regra de entrada: SSH restrito ao IP do aluno
  ingress {
    description = "SSH restrito ao meu IP"
    from_port   = var.porta_ssh
    to_port     = var.porta_ssh
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip]
  }

  # Regra de saida: permite todo trafego de saida
  egress {
    description = "Permite todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.nome_servidor}-sg"
  })
}

resource "aws_instance" "servidor_web" {
  ami                         = var.ami_id
  instance_type               = var.tipo_instancia
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.servidor_web.id]
  associate_public_ip_address = true
  user_data                   = var.user_data

  tags = merge(var.tags, {
    Name = var.nome_servidor
  })
}
