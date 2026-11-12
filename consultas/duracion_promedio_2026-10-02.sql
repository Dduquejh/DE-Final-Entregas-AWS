-- Duración promedio de las entregas exitosas del 2 de octubre de 2026.
-- Un único promedio para la fecha (todas las ciudades y transportadoras).
-- Solo estado 'entregado': los intentos fallidos tienen duración 0 y no se incluyen.
-- El CAST a DECIMAL(10,2) redondea y conserva dos decimales.
SELECT
    fecha,
    CAST(AVG(CAST(duracion_minutos AS DOUBLE)) AS DECIMAL(10, 2)) AS duracion_promedio_minutos
FROM mensajeria_entregas.intentos_entrega
WHERE fecha = '2026-10-02'
  AND estado = 'entregado'
GROUP BY fecha;
