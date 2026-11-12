output "region" {
  description = "Región del despliegue"
  value       = var.region
}

output "bucket_nombre" {
  description = "Nombre del bucket S3 del ejercicio"
  value       = aws_s3_bucket.datos.bucket
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.datos.arn
}

output "ubicacion_entregas" {
  description = "Prefijo S3 donde se cargan los CSV (entregas/fecha=yyyy-MM-dd/entregas.csv)"
  value       = local.ubicacion_entregas
}

output "ubicacion_resultados_athena" {
  description = "Prefijo S3 donde Athena escribe los resultados"
  value       = local.ubicacion_resultados
}

output "glue_base_datos" {
  description = "Base de datos de Glue Data Catalog"
  value       = aws_glue_catalog_database.entregas.name
}

output "glue_tabla" {
  description = "Tabla externa con partition projection"
  value       = aws_glue_catalog_table.entregas.name
}

output "tabla_completa" {
  description = "Nombre calificado para usar en las consultas SQL"
  value       = "${aws_glue_catalog_database.entregas.name}.${aws_glue_catalog_table.entregas.name}"
}

output "rango_proyeccion" {
  description = "Rango de fechas proyectado"
  value       = aws_glue_catalog_table.entregas.parameters["projection.fecha.range"]
}

output "athena_workgroup" {
  description = "Workgroup de Athena para ejecutar las consultas"
  value       = aws_athena_workgroup.entregas.name
}
