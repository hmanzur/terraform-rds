variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "Cloud DB"
}

variable "environment" {
  description = "The environment for the project"
  type        = string
  default     = "PeEx"
}

variable "zones" {
  type        = list(string)
  description = "value of zones to create"
  default     = null
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}

variable "db_storage_type" {
  description = "The storage type for the database"
  type        = string
  default     = "gp2"
}

variable "db_instance_class" {
  description = "The instance class for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The allocated storage for the database in GB"
  type        = number
  default     = 20
}

variable "db_major_engine_version" {
  description = "The major version of the database engine"
  type        = string
  default     = "14"
}