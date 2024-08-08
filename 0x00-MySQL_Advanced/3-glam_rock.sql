-- 3-glam_rock.sql: List bands with Glam rock as main style, ranked by longevity

SELECT name AS band_name, 
       IFNULL(YEAR(2022) - YEAR(formed), 0) AS lifespan
FROM metal_bands
WHERE style = 'Glam rock'
ORDER BY lifespan DESC;
