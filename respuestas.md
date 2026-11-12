# Respuestas

## 1. ¿Por qué se pudo consultar el tercer día sin registrar una partición nueva?

Porque la tabla `intentos_entrega` no depende de particiones registradas en Glue Data Catalog. Tiene habilitado **partition projection** (`projection.enabled = true`), y con eso Athena no busca en el catálogo qué particiones existen: las calcula en el momento de cada consulta a partir de las reglas guardadas en las propiedades de la tabla.

Esas reglas, definidas en `infraestructura/principal.tf`, son:

- `projection.fecha.type = date`, con formato `yyyy-MM-dd` e intervalo de 1 día (`DAYS`).
- `projection.fecha.range = 2026-10-01,2026-10-03`.
- `storage.location.template = s3://<bucket>/entregas/fecha=${fecha}/`.

Con el rango y el intervalo, Athena genera los valores posibles de `fecha` (2026-10-01, 2026-10-02 y 2026-10-03). Con la plantilla, reemplaza `${fecha}` por cada valor y obtiene el prefijo de S3 que debe leer. El día 3 estuvo dentro del rango **desde el despliegue inicial**, así que su ubicación ya se podía calcular antes de que existiera el archivo. En la etapa inicial ese prefijo estaba vacío y Athena simplemente no encontró filas; por eso el conteo fue 12. La proyección no crea datos ni exige que existan.



## 2. Si se subiera un archivo para el 4 de octubre manteniendo la configuración actual, ¿qué resultado se esperaría y qué se debería modificar para incluirlo?

**Resultado esperado.** El archivo quedaría guardado en S3, pero Athena no lo leería. El rango proyectado termina en `2026-10-03`, así que `2026-10-04` no está entre los valores que Athena genera para `fecha` y nunca calcula ese prefijo. En la práctica:

- La consulta no da error.
- `SELECT COUNT(*)` seguiría devolviendo 18.
- Una consulta con `WHERE fecha = '2026-10-04'` devolvería cero filas.
- Las consultas agregadas mostrarían los mismos resultados que en la etapa final.

Es el mismo comportamiento que tendría cualquier fecha fuera del rango: con partition projection, lo que no está proyectado no existe para Athena aunque haya objetos en S3.

**Qué modificar.** Basta con ampliar el rango de la proyección. No hace falta registrar la partición.

1. Cambiar el fin del rango en Terraform, por ejemplo `fecha_fin_proyeccion = "2026-10-04"` en `variables.tf` o en `terraform.tfvars`. Esto actualiza `projection.fecha.range` a `2026-10-01,2026-10-04`.
2. Ejecutar `terraform apply`. Terraform solo actualiza las propiedades de la tabla; no toca los datos ni crea particiones.
3. Comprobar que el archivo esté en `s3://<bucket>/entregas/fecha=2026-10-04/entregas.csv`, con el mismo esquema y encabezado.
4. Ampliar el filtro de las consultas agregadas. Hoy filtran `fecha BETWEEN '2026-10-01' AND '2026-10-03'`, así que habría que cambiar el límite a `'2026-10-04'` para que ese día aparezca en los resultados.

Si se espera recibir archivos todos los días, se puede usar un rango abierto como `2026-10-01,NOW`. Así cada fecha nueva queda incluida sin volver a cambiar la tabla. A cambio, Athena proyecta todas las fechas hasta hoy aunque no tengan datos, por lo que conviene filtrar siempre por `fecha` en las consultas.