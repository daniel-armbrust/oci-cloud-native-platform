#
# nosql/variables.tf
#

variable "compartment_id" {
    description = "ID do compartimento onde os recursos serão criados"
    type = string  
}

variable "table_name" {
    description = "Nome da tabela"
    type = string
}

variable "ddl" {
    description = "Comando DDL do Oracle NoSQL usado para definir o schema da tabela (CREATE TABLE, ALTER TABLE, etc.)."
    type = string
}

variable "is_auto_reclaimable" {
    description = "Indica se a tabela pode ser automaticamente recuperada ou reutilizada após exclusão"
    type = bool
    default = false
}

variable "max_read_units" {
    description = "Quantidade máxima de unidades de leitura permitidas para a tabela"
    type = number
}

variable "max_write_units" {
    description = "Quantidade máxima de unidades de escrita permitidas para a tabela"
    type = number
}

variable "max_storage_in_gbs" {
    description = "Limite máximo de armazenamento da tabela em gigabytes"
    type = number
}

variable "capacity_mode" {
    description = "Modo de capacidade da tabela (PROVISIONED ou ON_DEMAND)"
    type = string
    default = "PROVISIONED"
}

variable "create_replica" {
  description = "Se true, cria a réplica da tabela"
  type = bool
  default = false
}

variable "replica_table_id" {
    description = "ID da tabela que será replicada"
    type = string
    default = null
}

variable "replica_region" {
  description = "Região da réplica"
  type = string
  default = null
}