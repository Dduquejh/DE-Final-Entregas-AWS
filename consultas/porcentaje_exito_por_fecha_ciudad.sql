-- Porcentaje de entregas exitosas por fecha y ciudad.
-- porcentaje_exito = 100 * entregas con estado 'entregado' / total de intentos del grupo.
-- El denominador incluye todos los estados. 100.0 evita la división entera y el
-- CAST a DECIMAL(5,2) redondea y conserva siempre dos decimales (ej. 50.00).
SELECT
    fecha,
    ciudad,
    CAST(
        100.0 * SUM(CASE WHEN estado = 'entregado' THEN 1 ELSE 0 END) / COUNT(*)
        AS DECIMAL(5, 2)
    ) AS porcentaje_exito
FROM mensajeria_entregas.intentos_entrega
WHERE fecha BETWEEN '2026-10-01' AND '2026-10-03'
GROUP BY fecha, ciudad
ORDER BY fecha ASC, ciudad ASC;
