###############################################################################
# Configuración de Terraform y proveedor
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.etiquetas
  }
}

locals {
  prefijo_entregas   = "entregas/"
  prefijo_resultados = "resultados-athena/"

  ubicacion_entregas   = "s3://${aws_s3_bucket.datos.bucket}/${local.prefijo_entregas}"
  ubicacion_resultados = "s3://${aws_s3_bucket.datos.bucket}/${local.prefijo_resultados}"
}

###############################################################################
# 1. Bucket S3 privado (datos en entregas/ y resultados en resultados-athena/)
###############################################################################

resource "aws_s3_bucket" "datos" {
  bucket = var.nombre_bucket

  # Permite que terraform destroy elimine el bucket aunque queden objetos
  # (CSV cargados y resultados de Athena).
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "datos" {
  bucket = aws_s3_bucket.datos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "datos" {
  bucket = aws_s3_bucket.datos.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "datos" {
  bucket = aws_s3_bucket.datos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Nota: los prefijos entregas/ y resultados-athena/ no se crean como objetos.
# Son parte de las claves de los archivos y aparecen al subir los CSV o al
# ejecutar la primera consulta en Athena.

###############################################################################
# 2. Base de datos de Glue Data Catalog
###############################################################################

resource "aws_glue_catalog_database" "entregas" {
  name        = var.nombre_base_datos
  description = "Base de datos del ejercicio de intentos de entrega con partition projection"
}

###############################################################################
# 3. Tabla externa con partition projection por fecha
###############################################################################

resource "aws_glue_catalog_table" "entregas" {
  name          = var.nombre_tabla
  database_name = aws_glue_catalog_database.entregas.name
  description   = "Intentos de entrega diarios en CSV, particionados por fecha (proyección)"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL                 = "TRUE"
    classification           = "csv"
    "skip.header.line.count" = "1"

    # Partition projection: Athena calcula las particiones en tiempo de consulta
    "projection.enabled"             = "true"
    "projection.fecha.type"          = "date"
    "projection.fecha.format"        = "yyyy-MM-dd"
    "projection.fecha.range"         = "${var.fecha_inicio_proyeccion},${var.fecha_fin_proyeccion}"
    "projection.fecha.interval"      = "1"
    "projection.fecha.interval.unit" = "DAYS"

    # $${fecha} se escapa con doble $ para que Terraform no lo interpole y
    # llegue literal como ${fecha} a Glue. La plantilla termina en "/" porque
    # describe el prefijo de la partición, no el archivo.
    "storage.location.template" = "${local.ubicacion_entregas}fecha=$${fecha}/"
  }

  partition_keys {
    name    = "fecha"
    type    = "string"
    comment = "Fecha del archivo (carpeta fecha=yyyy-MM-dd), no es columna del CSV"
  }

  storage_descriptor {
    location      = local.ubicacion_entregas
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "csv-lazy-simple"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"          = ","
        "serialization.format" = ","
      }
    }

    columns {
      name    = "id_envio"
      type    = "string"
      comment = "Identificador único del envío"
    }

    columns {
      name    = "ciudad"
      type    = "string"
      comment = "Ciudad del intento de entrega"
    }

    columns {
      name    = "transportadora"
      type    = "string"
      comment = "Transportadora responsable"
    }

    columns {
      name    = "estado"
      type    = "string"
      comment = "entregado, destinatario_ausente o direccion_incorrecta"
    }

    columns {
      name    = "duracion_minutos"
      type    = "int"
      comment = "Duración en minutos; 0 para intentos fallidos"
    }
  }
}

###############################################################################
# 4. Workgroup de Athena con resultados en resultados-athena/
###############################################################################

resource "aws_athena_workgroup" "entregas" {
  name        = var.nombre_workgroup
  description = "Workgroup para las consultas del ejercicio de entregas"
  state       = "ENABLED"

  # Elimina el historial de consultas guardadas al destruir el workgroup.
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = local.ubicacion_resultados

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}
