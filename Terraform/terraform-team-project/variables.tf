variable "awsprops" {
  type = map(string)
  default = {
    keyname      = "keyname"
    instancetype = "t2.micro"

  }

}

variable "dbprops" {
  type = map(string)
  default = {
    identifier = "aws_console_db_identifier"
    DbName     = "dbname"
    username   = "admin"
    password   = ""
    engine = "mysql"
    engine_version = "8.0.25"
    instance_class = "db.t2.micro"
  }

}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}