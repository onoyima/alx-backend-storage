-- Task 3: List all bands with Glam rock as their main style, ranked by their longevity
-- This script lists all bands with Glam rock as their main style, calculating their lifespan from the year they were formed until 2022, and orders them by their lifespan in descending order.

SELECT 
    band_name, 
    (IFNULL(split, 2022) - formed) AS lifespan
FROM 
    metal_bands
WHERE 
    FIND_IN_SET('Glam rock', IFNULL(style, '')) > 0
ORDER BY 
    lifespan DESC;
