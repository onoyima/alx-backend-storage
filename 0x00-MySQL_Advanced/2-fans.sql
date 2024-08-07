-- Task 2: Rank country origins of bands by number of fans
SELECT origin, nb_fans
FROM bands
ORDER BY nb_fans DESC;
