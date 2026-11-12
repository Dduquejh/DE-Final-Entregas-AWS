-- Cantidad de intentos por fecha y estado.
-- Cuenta todos los intentos (éxitos y fallos) y ordena por fecha y luego estado.
-- El filtro cubre todo el rango proyectado, así la misma consulta sirve en la
-- etapa inicial (días 1 y 2) y en la final (días 1 a 3) sin cambiar el SQL.
SELECT
    fecha,
    estado,
    COUNT(*) AS total_intentos
FROM mensajeria_entregas.intentos_entrega
WHERE fecha BETWEEN '2026-10-01' AND '2026-10-03'
GROUP BY fecha, estado
ORDER BY fecha ASC, estado ASC;
