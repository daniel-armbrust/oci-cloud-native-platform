#
# objectstorage/variables.tf
#

variable "compartment_id" {
  description = "ID do compartimento onde os recursos serão criados"
  type        = string
}

variable "bucket_name" {
  description = "Nome do bucket"
  type        = string
}

variable "access_type" {
  description = "Nível de acesso permitido no bucket"
  type        = string
}

variable "namespace" {
  description = "OCI Object Storage namespace"
  type        = string
}

variable "replica_bucket_name" {
  description = "Nome do bucket que será replicado"
  type        = string
  default     = null
}

variable "replica_region" {
  description = "Região da réplica"
  type        = string
  default     = null
}

variable "file_list" {
  description = "Lista opcional de arquivos locais para upload no bucket"
  type        = list(string)
  default     = []
}
