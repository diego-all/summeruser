# Grupo de Seguridad para la Base de Datos
resource "aws_security_group" "rds_sg" {
  name        = "SummerDBSecurityGroup"
  description = "Grupo de seguridad para la base de datos de Summer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Permitir conexion externa al puerto MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia RDS MySQL (SummerRdsStack)
resource "aws_db_instance" "summer_rds" {
  identifier            = "summer"
  allocated_storage     = 20
  max_allocated_storage = 20 # Evita auto-scaling de almacenamiento
  storage_type          = "gp2"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"

  # Nombre de la BD corregido según el CDK original
  db_name  = "summer"
  username = "root"
  password = "summer2026"

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Retención de backups (7 días)
  backup_retention_period    = 7
  auto_minor_version_upgrade = false

  # Equivalente a RemovalPolicy.DESTROY / deletion_protection = False
  deletion_protection = false
  skip_final_snapshot = true
}

# ========================================================================
# CARGA INICIAL DE LA BASE DE DATOS (volcado de HeidiSQL en sql/init.sql)
# ========================================================================
# CAMBIO: Terraform no ejecuta SQL por sí solo. Se usa local-exec con el cliente "mysql" de tu máquina
# (sudo apt install mysql-client). Requiere Terraform >= 1.4 por terraform_data.
# Se vuelve a ejecutar si la RDS se recrea o si cambia el contenido de sql/init.sql.
# El script usa CREATE TABLE IF NOT EXISTS, así que se puede repetir sin romper nada.
resource "terraform_data" "rds_init_schema" {
  triggers_replace = [
    aws_db_instance.summer_rds.id,
    filesha256("${path.module}/../bd/init.sql"),
  ]

  provisioner "local-exec" {
    # La contraseña va por variable de entorno para que no aparezca en la línea de comandos
    environment = {
      MYSQL_PWD = aws_db_instance.summer_rds.password
    }

    # Reintenta hasta 12 veces (2 minutos): el endpoint puede tardar un poco en responder aunque la RDS ya figure disponible
    command = <<-EOT
      for i in $(seq 1 12); do
        mysql --connect-timeout=10 -h ${aws_db_instance.summer_rds.address} -u ${aws_db_instance.summer_rds.username} -e 'SELECT 1' && break
        echo "Esperando a la RDS ($i/12)..."
        sleep 10
      done
      mysql -h ${aws_db_instance.summer_rds.address} -u ${aws_db_instance.summer_rds.username} ${aws_db_instance.summer_rds.db_name} < ${path.module}/../bd/init.sql
    EOT
  }
}

# Usuario administrador (User_Status = 0). Solo se crea si defines admin_user_uuid en terraform.tfvars.
# UserIsAdmin del backend busca este registro; sin él el POST responde "User is not Admin".
# El UUID es el claim "username" del access token (jwt.io). ON DUPLICATE KEY lo deja como admin si ya existía.
resource "terraform_data" "rds_init_admin" {
  count = var.admin_user_uuid != "" ? 1 : 0

  triggers_replace = [
    terraform_data.rds_init_schema.id,
    var.admin_user_uuid,
    var.admin_user_email,
  ]

  provisioner "local-exec" {
    environment = {
      MYSQL_PWD = aws_db_instance.summer_rds.password
    }

    command = <<-EOT
      mysql -h ${aws_db_instance.summer_rds.address} -u ${aws_db_instance.summer_rds.username} ${aws_db_instance.summer_rds.db_name} -e "INSERT INTO users (User_UUID, User_Email, User_Status, User_DateAdd) VALUES ('${var.admin_user_uuid}', '${var.admin_user_email}', 0, NOW()) ON DUPLICATE KEY UPDATE User_Status = 0;"
    EOT
  }
}
