-- 2-fans.sql: Rank countries by number of fans from metal_bands table

SELECT origin, SUM(fans) AS nb_fans
FROM metal_bands
GROUP BY origin
ORDER BY nb_fans DESC;
