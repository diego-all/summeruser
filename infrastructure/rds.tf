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
  identifier                  = "summer"
  allocated_storage           = 20
  max_allocated_storage       = 20 # Evita auto-scaling de almacenamiento
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = "db.t3.micro"
  
  # Nombre de la BD corregido según el CDK original
  db_name                     = "summer"
  username                    = "root"
  password                    = "summer2026"
  
  publicly_accessible         = true
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  
  # Retención de backups (7 días)
  backup_retention_period     = 7
  auto_minor_version_upgrade  = false
  
  # Equivalente a RemovalPolicy.DESTROY / deletion_protection = False
  deletion_protection         = false
  skip_final_snapshot         = true
}