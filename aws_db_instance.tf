##
#
# AWS database instances
#
##

# Define local varibles that notate what the AWS free tier can do.
locals {
  aws_db_instance__instance_class__free_tier = "db.t2.micro"
  aws_db_instance__allocated_storage__free_tier = "20"
}

resource "aws_db_instance" "demo" {

  # The name of the RDS instance.
  # Letters and hyphens are allowed; underscores are not.
  # Terraform default is  a random, unique identifier. 
  identifier = "demo-rds"

  # The name of the database to create when the DB instance is created. 
  name = "demo_db"

  # The RDS instance class.
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  instance_class       = local.aws_db_instance__instance_class__free_tier

  # The allocated storage in gibibytes. 
  allocated_storage    = local.aws_db_instance__allocated_storage__free_tier

  # The database engine name such as "postgres", "mysql", "aurora", etc.
  # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  engine               = "postgres"

  # The master account username and password.
  # Note that these settings may show up in logs,
  # and will be stored in the state file in raw text.
  #
  # We strongly recommend doing this differently if you
  # are building a production system or secure system.
  #
  # These variables are set in the file .env.auto.tfvars
  # and you can see the example ffile .env.example.auto.tfvars.
  username             = var.aws_db_demo_username  # e.g. "postgres"
  password             = var.aws_db_demo_password  # e.g. "secret"

  # We like to use the database with public tools such as DB admin apps.
  publicly_accessible = "true"

  # We like performance insights, which help us optimize the data use.
  performance_insights_enabled = "true"

  # We like to have the demo database update to the current version.
  allow_major_version_upgrade = "true"

  # We like backup retention for as long as possible.
  backup_retention_period = "35"

  # Backup window time in UTC is in the middle of the night in the United States.
  backup_window = "08:00-09:00"

  # We prefer to preserve the backups if the database is accidentally deleted.
  delete_automated_backups = "false"

  # Maintenance window is after backup window, and on Sunday, and in the middle of the night.
  maintenance_window = "sun:09:00-sun:10:00"

}
