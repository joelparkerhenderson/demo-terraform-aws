##
#
# AWS database instance
#
##

# Define local varibles that notate what the AWS free tier can do.
locals {
  aws_db_instance__instance_class__free_tier = "db.t2.micro"
  aws_db_instance__allocated_storage__free_tier = "20"
}

variable "aws_db_instance__demo__username" {
  default = "postgres"
}

variable "aws_db_instance__demo__password" {
  default = "secret"
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
  username             = var.aws_db_instance__demo__username
  password             = var.aws_db_instance__demo__password

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

##
#
# Database instance a.k.a. database object
#
##

# The "owner" role has full permissions.
variable "postgresql_role__owner__name" {
  default = "owner"
}

variable "postgresql_role__owner__password" {
  default = "secret"
}

# The "deployer" role is intended for releases, migrations, etc.
variable "postgresql_role__deployer__name" {
  default = "deployer"
}

variable "postgresql_role__deployer__password" {
  default = "secret"
}

# The "reader" role is intended for read-only actions.
variable "postgresql_role__reader__name" {
  default = "reader"
}

variable "postgresql_role__reader__password" {
  default = "secret"
}

variable "postgresql_database__name" {
  default = "demo"
}

# Equivalent SQL:
#
#     CREATE ROLE 'owner' WITH LOGIN 
#     ENCRYPTED PASSWORD 'secret';
#
resource "postgresql_role" "owner" {
  name     = var.postgresql_role__owner__name
  password = var.postgresql_role__owner__password
  login    = true
  replication = true
  connection_limit = -1
}

# Equivalent SQL:
#
#     CREATE ROLE 'deployer' WITH LOGIN 
#     ENCRYPTED PASSWORD 'secret';
#
resource "postgresql_role" "deployer" {
  name     = var.postgresql_role__deployer__name
  password = var.postgresql_role__deployer__password
  login    = true
  replication = true
  connection_limit = -1
}

# Equivalent SQL:
#
#     CREATE ROLE 'reader' WITH LOGIN 
#     ENCRYPTED PASSWORD 'secret';
#
resource "postgresql_role" "reader" {
  name     = var.postgresql_role__reader__name
  password = var.postgresql_role__reader__password
  login    = true
  replication = true
  connection_limit = -1
}

# Equivalent SQL:
#
#     CREATE SCHEMA 'public';
#
resource "postgresql_schema" "public" {
  name = "public"
  owner = "postgres"

  # The "owner" role can do everything.
  # This is the role that has full access.
  policy {
    create_with_grant = true
    usage_with_grant  = true
    role              = "${postgresql_role.owner.name}"
  }

  # The "deployer" role can create new objects in the schema
  # This is the role that runs releases, migrations, etc.
  policy {
    create_with_grant = true
    usage_with_grant  = true
    role   = "${postgresql_role.deployer.name}"
  }

  # The "reader" role can read everything by default.
  # This is the role that must never has write access.
  policy {
    usage = true
    role  = "${postgresql_role.reader.name}"
  }

}

# Equivalent SQL:
#
#     CREATE DATABASE demo;
#
resource "postgresql_database" "demo" {
  name              = var.postgresql_database__name
  owner             = var.postgresql_role__name
  template          = "template0"
  encoding          = "UTF8"
  lc_collate        = "C"
  lc_ctype          = "C"
  connection_limit  = 1
  allow_connections = true
}

# Equivalent SQL:
#
#     GRANT ALL ON DATABASE 'demo' TO 'owner';
#
resource "postgresql_grant" "owner" {
  database    = var.postgresql_database__name
  role        = var.postgresql_role__owner__name
  schema      = "public"
  object_type = "database"
  privileges  = ["ALL"]
}

# Equivalent SQL:
#
#     GRANT ALL ON DATABASE 'demo' TO 'deployer';
#
resource "postgresql_grant" "deployer" {
  database    = var.postgresql_database__name
  role        = var.postgresql_role__deployer__name
  schema      = "public"
  object_type = "database"
  privileges  = ["ALL"]
}

# Equivalent SQL:
#
#     GRANT SELECT ON ALL TABLES
#     IN SCHEMA public
#     TO reader;
#
resource "postgresql_grant" "reader" {
  database    = var.postgresql_database__name
  role        = var.postgresql_role__reader__name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT"]
}

# Equivalent SQL:
#
#     ALTER DEFAULT PRIVILEGES
#     IN SCHEMA public
#     GRANT SELECT ON TABLES TO reader;
#
resource "postgresql_default_privileges" "reader" {
  database = var.postgresql_database__name
  role     = var.postgresql_role__reader__name
  schema   = "public"
  owner       = var.postgresql_role__reader__name
  object_type = "table"
  privileges  = ["SELECT"]
}
