--zadanie3
CREATE EXTENSION postgis;

--zadanie4
CREATE TABLE budynki (id INTEGER, geometria GEOMETRY, nazwa VARCHAR(30));
CREATE TABLE drogi (id INTEGER, geometria GEOMETRY, nazwa VARCHAR(30));
CREATE TABLE punkty_informacyjne (id INTEGER, geometria GEOMETRY, nazwa VARCHAR(30));

--zadanie5
INSERT INTO budynki VALUES (2, ST_GeomFromText('POLYGON((8 1.5, 8 4, 10.5 4, 10.5 1.5, 8 1.5))',0), 'BuildingA');
INSERT INTO budynki VALUES (3, ST_GeomFromText('POLYGON((4 5, 4 7, 6 7, 6 5, 4 5))',0), 'BuildingB');
INSERT INTO budynki VALUES (4, ST_GeomFromText('POLYGON((3 6, 3 8, 5 8, 5 6, 3 6))',0), 'BuildingC');
INSERT INTO budynki VALUES (5, ST_GeomFromText('POLYGON((9 8, 9 9, 10 9, 10 8, 9 8))',0), 'BuildingD');
INSERT INTO budynki VALUES (1, ST_GeomFromText('POLYGON((1 1, 1 2, 2 2, 2 1, 1 1))',0), 'BuildingF');

INSERT INTO drogi VALUES (1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)',0), 'RoadX');
INSERT INTO drogi VALUES (2, ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)',0), 'RoadY');

INSERT INTO punkty_informacyjne VALUES (1, ST_GeomFromText('POINT(1 3.5)',0), 'G');
INSERT INTO punkty_informacyjne VALUES (2, ST_GeomFromText('POINT(5.5 1.5)',0), 'H');
INSERT INTO punkty_informacyjne VALUES (3, ST_GeomFromText('POINT(9.5 6)',0), 'I');
INSERT INTO punkty_informacyjne VALUES (4, ST_GeomFromText('POINT(6.5 6)',0), 'J');
INSERT INTO punkty_informacyjne VALUES (5, ST_GeomFromText('POINT(6 9.5)',0), 'K');

--zadanie6
--a
SELECT SUM (ST_Length(geometria)) FROM drogi;

--b
SELECT ST_AsText(geometria) AS WKT, ST_Area(geometria) AS pole_powierzchni, ST_Perimeter(geometria) AS obwod_poligonu
FROM budynki WHERE nazwa='BuildingA';

--c
SELECT nazwa, ST_Area(geometria) AS pole_powierzchni FROM budynki ORDER BY nazwa;

--d
SELECT nazwa, ST_Perimeter(geometria) AS obwod_poligonu FROM budynki ORDER BY obwod_poligonu DESC LIMIT 2;

--e
SELECT ST_Distance(budynki.geometria, punkty_informacyjne.geometria) AS najkrótsza_odleglosc FROM budynki, punkty_informacyjne
WHERE budynki.nazwa='BuildingC' AND punkty_informacyjne.nazwa='G';

--f
CREATE TABLE bufor1 AS SELECT ST_Buffer(geometria, 0.5) AS bufor_1 FROM budynki WHERE nazwa='BuildingB';
CREATE TABLE bufor2 AS SELECT geometria FROM budynki WHERE nazwa='BuildingC';
SELECT ST_Area(ST_Difference(geometria, bufor_1)) AS czesc_pola_powierzchni FROM bufor2, bufor1;

--g
SELECT budynki.nazwa, ST_Y(ST_CENTROID(budynki.geometria)) AS powyzej_drogiX FROM budynki WHERE ST_Y(ST_CENTROID(budynki.geometria)) > 4.5;

--h
SELECT ST_Area(ST_Difference(geometria, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 0))) AS pole_roznicy FROM bufor2;
