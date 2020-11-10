CREATE EXTENSION postgis;

CREATE TABLE obiekty (id INT, nazwa VARCHAR(20), geometria GEOMETRY);

INSERT INTO obiekty VALUES(1, 'Obiekt1', ST_GeomFromText('MULTICURVE((0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1), CIRCULARSTRING(3 1, 4 2, 5 1), (5 1, 6 1))',0));
INSERT INTO obiekty VALUES(2, 'Obiekt2', ST_GeomFromText('CURVEPOLYGON(COMPOUNDCURVE((10 6, 14 6), CIRCULARSTRING(14 6, 16 4, 14 2, 12 0, 10 2), (10 2, 10 6)), CIRCULARSTRING(11 2, 13 2, 11 2) )',0));
INSERT INTO obiekty VALUES(3, 'Obiekt3', ST_GeomFromText('POLYGON((12 13, 7 15, 10 17, 12 13))',0));
INSERT INTO obiekty VALUES(4, 'Obiekt4', ST_GeomFromText('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)', 0));
INSERT INTO obiekty VALUES(5, 'Obiekt5', ST_GeomFromText('MULTIPOINT Z((30 30 59), (38 32 234))',0));
INSERT INTO obiekty VALUES(6, 'Obiekt6', ST_GeomFromText('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2), POINT(4 2))',0));

--zadanie 1
SELECT ST_Area(ST_Buffer(ST_ShortestLine((SELECT geometria FROM obiekty WHERE nazwa LIKE 'Obiekt3'),(SELECT geometria FROM obiekty WHERE nazwa LIKE 'Obiekt4')),5)) 
AS pole_powierzchni;

--zadanie 2
UPDATE obiekty SET geometria = ST_GeomFromText('POLYGON((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20))', 0) WHERE nazwa LIKE 'Obiekt4';
--Aby wykonać zadanie (utworzyć poligon) należało z linii stworzyć obiekt zamknięty za pomocą dodania dodatkowej lini.

--zadanie 3
SELECT geometria FROM obiekty WHERE nazwa LIKE 'Obiekt3' OR nazwa LIKE 'Obiekt4';
INSERT INTO obiekty VALUES(7, 'Obiekt7', ST_GeomFromText('MULTIPOLYGON(((12 13, 7 15, 10 17, 12 13)),((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20)))',0));
						   
--zadanie 4
SELECT SUM (ST_Area(ST_Buffer(geometria, 5))) AS pole_powierzchni FROM obiekty WHERE ST_HasArc(geometria) = false;
