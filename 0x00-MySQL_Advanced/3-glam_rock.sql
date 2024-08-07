-- Task 3: List all bands with Glam rock as their main style, ranked by longevity
SELECT band_name, (2022 - formed) AS lifespan
FROM bands
WHERE style = 'Glam rock'
ORDER BY lifespan DESC;
