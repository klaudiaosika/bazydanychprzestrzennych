CREATE EXTENSION postgis;

--zadanie 4
CREATE TABLE tableB AS SELECT COUNT (DISTINCT popp.gid) AS liczba_budynkow FROM popp, majrivers WHERE popp.f_codedesc LIKE 'Building' AND ST_Intersects (ST_Buffer(majrivers.geom, 100000), popp.geom);
SELECT * FROM tableB;

--zadanie 5
SELECT name, geom, elev INTO airportsNew FROM airports;

--zadanie 5a
SELECT name AS Zachod, ST_Y(geom) AS Wspolrzedne FROM airportsNew ORDER BY Wspolrzedne ASC LIMIT 1;
SELECT name AS Wschod, ST_Y(geom) AS Wspolrzedne FROM airportsNew ORDER BY Wspolrzedne DESC LIMIT 1;

--zadanie 5b
INSERT INTO airportsNew VALUES ('airportB', (SELECT ST_Centroid (ST_ShortestLine((SELECT geom FROM airportsNew WHERE name LIKE 'NIKOLSKI AS'),(SELECT geom FROM airportsNew WHERE name LIKE 'NOATAK')))), 100);

--zadanie 6
SELECT ST_Area(ST_Buffer(ST_ShortestLine(airports.geom, lakes.geom),1000)) AS pole_powierzchni 
FROM airports, lakes WHERE airports.name LIKE 'AMBLER' AND lakes.names LIKE 'Iliamna Lake';

--zadanie 7
SELECT SUM(swamp.areakm2 + tundra.area_km2) pole_powierzchni, trees.vegdesc typ_drzewa FROM swamp, tundra, trees 
WHERE swamp.areakm2 IN (SELECT swamp.areakm2 FROM swamp, trees WHERE ST_CONTAINS(swamp.geom, trees.geom) = 'true') 
AND tundra.area_km2 IN (SELECT tundra.area_km2 FROM tundra, trees WHERE ST_CONTAINS(tundra.geom, trees.geom) = 'true') GROUP BY trees.vegdesc;