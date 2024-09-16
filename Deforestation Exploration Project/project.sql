/*
Create a VIEW called forestation
*/
CREATE VIEW forestation AS
SELECT fa.country_code AS country_code,
       fa.country_name AS country_name,
       fa.year AS year,
       fa.forest_area_sqkm AS forest_area_sqkm,
       la.total_area_sq_mi AS total_area_sq_mi,
       r.region AS region,
       r.income_group AS income_group,(fa.forest_area_sqkm/(la.total_area_sq_mi*2.59))*100 AS percent_forest
FROM forest_area AS fa, land_area AS la, regions AS r
WHERE fa.country_code = la.country_code AND fa.year = la.year AND la.country_code = r.country_code;

/* --- PART 1 --- */

/*
a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that
you can use the country record denoted as “World" in the region table.
b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that
you can use the country record in the table is denoted as “World.”
*/
SELECT country_name, year, forest_area_sqkm
FROM forestation
WHERE country_name = 'World' AND (YEAR = '1990' OR YEAR = '2016')
ORDER BY year;

/*
c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
*/
SELECT (af.forest_area_sqkm - bf.forest_area_sqkm) AS forest_area_change_sqkm
FROM forestation AS af, forestation AS bf
WHERE af.year = '2016' AND af.country_name = 'World'
AND bf.year = '1990' AND bf.country_name = 'World';

/*
d. What was the percent change in forest area of the world between 1990 and 2016?
*/
SELECT (((af.forest_area_sqkm/bf.forest_area_sqkm)-1)*100) AS percent_change_forest_area
FROM forestation AS af, forestation AS bf
WHERE af.year = '2016' AND af.country_name = 'World'
AND bf.year = '1990' AND bf.country_name = 'World';

/*
e. If you compare the amount of forest area lost between 1990 and 2016, to which country's
total area in 2016 is it closest to?
*/
SELECT country_name, (total_area_sq_mi*2.59) AS total_area_sqkm
FROM forestation
WHERE year = '2016' AND (total_area_sq_mi*2.59)>1270000
AND (total_area_sq_mi*2.59)<1324449;

/* --- PART 2 --- */

/*
a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST
percent forest in 2016, and which had the LOWEST, to 2 decimal places?
b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST
percent forest in 1990, and which had the LOWEST, to 2 decimal places?
c. Based on the table you created, which regions of the world DECREASED in forest area
from 1990 to 2016?
*/
SELECT bf.region, 
       bf.country_name, 
       bf.forest_area_sqkm AS forest_area_1990
FROM forestation AS bf;
SELECT ROUND (CAST((region_forest_1990/region_area_1990)*100 AS NUMERIC),2) AS forest_cover_1990,
       ROUND (CAST((region_forest_2016/region_area_2016)*100 AS NUMERIC),2) AS forest_cover_2016, 
       region
FROM (SELECT SUM(bf.forest_area_sqkm) AS region_forest_1990,
      SUM (bf.total_area_sq_mi*2.59) AS region_area_1990, 
      bf.region,
      SUM (af.forest_area_sqkm) AS region_forest_2016,
      SUM (af.total_area_sq_mi*2.59) AS region_area_2016
FROM forestation AS bf, forestation AS af
    WHERE bf.year = '1990'
    AND af.year = '2016'
    AND bf.region = af.region
GROUP BY bf.region) region_percent
ORDER BY forest_cover_1990 DESC;

/* --- PART 3 --- */

/*
To fill SUCCESS STORIES part 3
*/
SELECT af.country_name, 
       af.region, 
       ROUND (CAST(((af.forest_area_sqkmbf.forest_area_sqkm))AS NUMERIC),2) AS forest_area_change_sqkm
FROM forestation AS af
JOIN forestation AS bf
    ON (af.year = '2016' AND bf.year = '1990')
    AND af.country_code = bf.country_code
    WHERE af.country_name != 'World'
    AND af.forest_area_sqkm != 0 
    AND bf.forest_area_sqkm != 0
ORDER BY forest_area_change_sqkm DESC
LIMIT 5;

/*
a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016?
What was the difference in forest area for each?
*/
SELECT af.country_name, 
       af.region, 
       ROUND (CAST(((af.forest_area_sqkmbf.forest_area_sqkm))AS NUMERIC),2) AS forest_area_change_sqkm
FROM forestation AS af
JOIN forestation AS bf
    ON (af.year = '2016' AND bf.year = '1990')
    AND af.country_code = bf.country_code
    WHERE af.country_name != 'World'
ORDER BY forest_area_change_sqkm
LIMIT 5;

/*
b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016?
What was the percent change to 2 decimal places for each?
*/
SELECT af.country_name, 
       af.region, 
       ROUND (CAST(((af.forest_area_sqkm/bf.forest_area_sqkm-1)*100)AS NUMERIC),2) AS forest_area_change_percent
FROM forestation AS af
JOIN forestation AS bf
    ON (af.year = '2016' AND bf.year = '1990')
    AND af.country_code = bf.country_code
    WHERE af.country_name != 'World'
ORDER BY forest_area_change_percent
LIMIT 5;

/*
largest percent change in forest area from 1990 to 2016
*/
SELECT af.country_name, 
       af.region, 
       ROUND (CAST(((af.forest_area_sqkm/bf.forest_area_sqkm-1)*100)AS NUMERIC),2) AS forest_area_change_percent
FROM forestation AS af
JOIN forestation AS bf
ON (af.year = '2016' AND bf.year = '1990')
AND af.country_code = bf.country_code
WHERE bf.forest_area_sqkm != 0 AND af.forest_area_sqkm !=0
ORDER BY forest_area_change_percent DESC
LIMIT 1;

/*
c. If countries were grouped by percent forestation in quartiles, which group had the most
countries in it in 2016?
*/
WITH t1 AS
(SELECT country_name, year, forest_area_sqkm, total_area_sq_mi*2.59 AS total_area_sqkm, percent_forest
FROM forestation
WHERE (year = '2016' AND country_name != 'World'
       AND forest_area_sqkm != 0 
       AND total_area_sq_mi != 0)
ORDER BY percent_forest DESC),

t2 AS
(SELECT t1.country_name, t1.year, t1.percent_forest, 
    CASE WHEN t1.percent_forest > 75 THEN 4
    WHEN t1.percent_forest <= 75 AND t1.percent_forest > 50 THEN 3
    WHEN t1.percent_forest <= 50 AND t1.percent_forest > 25 THEN 2
    ELSE 1
    END AS percentile
 FROM t1
 ORDER BY 4 DESC)

SELECT t2.percentile, COUNT(t2.percentile)
FROM t2
GROUP BY 1
ORDER BY 2 DESC;

/*
d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
*/
SELECT country_name, 
       region, 
       ROUND (CAST((percent_forest) AS NUMERIC),2) AS percent
FROM forestation
WHERE (year = '2016' 
       AND country_name != 'World'
       AND forest_area_sqkm != 0 
       AND total_area_sq_mi != 0)
    AND percent_forest > 75
ORDER BY percent_forest DESC;
