variable "region" {
  description = "Región de AWS donde se despliegan los recursos"
  type        = string
  default     = "us-east-1"
}

variable "nombre_bucket" {
  description = "Nombre globalmente único del bucket S3 del ejercicio"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.nombre_bucket))
    error_message = "El nombre del bucket debe tener entre 3 y 63 caracteres: minúsculas, números, puntos o guiones."
  }
}

variable "nombre_base_datos" {
  description = "Nombre de la base de datos de Glue Data Catalog"
  type        = string
  default     = "mensajeria_entregas"

  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.nombre_base_datos))
    error_message = "Use solo minúsculas, números y guion bajo (compatible con Athena)."
  }
}

variable "nombre_tabla" {
  description = "Nombre de la tabla externa de intentos de entrega"
  type        = string
  default     = "intentos_entrega"

  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.nombre_tabla))
    error_message = "Use solo minúsculas, números y guion bajo (compatible con Athena)."
  }
}

variable "nombre_workgroup" {
  description = "Nombre del workgroup de Athena"
  type        = string
  default     = "wg-entregas"
}

variable "fecha_inicio_proyeccion" {
  description = "Primera fecha proyectada (yyyy-MM-dd, incluida)"
  type        = string
  default     = "2026-10-01"
}

variable "fecha_fin_proyeccion" {
  description = "Última fecha proyectada (yyyy-MM-dd, incluida)"
  type        = string
  default     = "2026-10-03"
}

variable "etiquetas" {
  description = "Etiquetas comunes para todos los recursos"
  type        = map(string)
  default = {
    Proyecto = "partition-projection-entregas"
    Gestion  = "terraform"
  }
}
