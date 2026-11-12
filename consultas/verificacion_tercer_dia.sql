-- Verificación de la incorporación del 2026-10-03 sin registrar particiones.
-- Athena ejecuta una sentencia por ejecución: correr cada bloque por separado
-- y guardar su resultado en el CSV indicado.

-- 1) Registros del tercer día (deben ser 6).
--    Resultado: resultados/final/verificacion_tercer_dia.csv
SELECT
    fecha,
    id_envio,
    ciudad,
    transportadora,
    estado,
    duracion_minutos
FROM mensajeria_entregas.intentos_entrega
WHERE fecha = '2026-10-03'
ORDER BY id_envio ASC;

-- 2) Total de registros de la tabla (debe ser 18) y registros por fecha.
--    Resultado: resultados/final/verificacion_total_registros.csv
SELECT
    COUNT(*) AS total_registros,
    COUNT_IF(fecha = '2026-10-01') AS registros_2026_10_01,
    COUNT_IF(fecha = '2026-10-02') AS registros_2026_10_02,
    COUNT_IF(fecha = '2026-10-03') AS registros_2026_10_03
FROM mensajeria_entregas.intentos_entrega
WHERE fecha BETWEEN '2026-10-01' AND '2026-10-03';

-- 3) Conteo por estado del tercer día.
--    Resultado: resultados/final/verificacion_conteo_estados_tercer_dia.csv
SELECT
    fecha,
    estado,
    COUNT(*) AS total_intentos
FROM mensajeria_entregas.intentos_entrega
WHERE fecha = '2026-10-03'
GROUP BY fecha, estado
ORDER BY estado ASC;
