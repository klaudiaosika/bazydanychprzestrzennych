CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

--Zmiana katalogu
cd "C:\Program Files\PostgreSQL\12\bin"

--Ładowanie danych
--Przykład 1 – ładowanie rastru przy użyciu pliku .sql
raster2pgsql.exe -s 3763 -N -32767 -t 100x100 -I -C -M -d 
C:\Users\klaud\Desktop\semestr5\bazy_danych_przestrzennych\cw5\rasters\rasters\srtm_1arc_v3.tif rasters.dem > C:\Users\klaud\Desktop\semestr5\bazy_danych_przestrzennych\cw5\dem.sql

--Przykład 2 – ładowanie rastru bezpośrednio do bazy
raster2pgsql.exe -s 3763 -N -32767 -t 100x100 -I -C -M -d 
C:\Users\klaud\Desktop\semestr5\bazy_danych_przestrzennych\cw5\rasters\rasters\srtm_1arc_v3.tif rasters.dem | psql -d postgis_raster -h localhost -U postgres -p 5432

--Przykład 3 – załadowanie danych landsat 8 o wielkości kafelka 128x128 bezpośrednio do bazy danych
raster2pgsql.exe -s 3763 -N -32767 -t 128x128 -I -C -M -d 
C:\Users\klaud\Desktop\semestr5\bazy_danych_przestrzennych\cw5\rasters\rasters\Landsat8_L1TP_RGBN.TIF rasters.landsat8 | psql -d postgis_raster -h localhost -U postgres -p 5432

--Tworzenie rastrów z istniejących rastrów i interakcja z wektorami
--PRZYKŁAD 1 - ST_Intersects
CREATE TABLE osika.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

--dodanie serial primary key
ALTER TABLE osika.intersects ADD COLUMN rid SERIAL PRIMARY KEY;
--utworzenie indeksu przestrzennego
CREATE INDEX idx_intersects_rast_gist ON osika.intersects USING gist (ST_ConvexHull(rast));
--dodanie raster constraints
-- schema::name table_name::name raster_column::name
SELECT AddRasterConstraints('osika'::name,'intersects'::name,'rast'::name);

--PRZYKŁAD 2 - ST_Clip
--obcinanie rastra na podstawie wektora
CREATE TABLE osika.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

--PRZYKŁAD 3 - ST_Union
--połączenie wielu kafelków w jeden raster
CREATE TABLE osika.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

--Tworzenie rastrów z wektorów (rastrowanie)
--PRZYKŁAD 1 - ST_AsRaster
CREATE TABLE osika.porto_parishes AS
WITH r AS (SELECT rast FROM rasters.dem LIMIT 1)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--PRZYKŁAD 2 - ST_Union
DROP TABLE osika.porto_parishes; 
CREATE TABLE osika.porto_parishes AS
WITH r AS (SELECT rast FROM rasters.dem LIMIT 1)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--PRZYKŁAD 3 - ST_Tile
DROP TABLE osika.porto_parishes; 
CREATE TABLE osika.porto_parishes AS
WITH r AS (SELECT rast FROM rasters.dem LIMIT 1)
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-
32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Konwertowanie rastrów na wektory (wektoryzowanie)
--PRZYKŁAD 1 - ST_Intersection
CREATE TABLE osika.intersection AS SELECT
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ILIKE 'paranhos' AND ST_Intersects(b.geom,a.rast);

--PRZYKŁAD 2 - ST_DumpAsPolygons
CREATE TABLE osika.dumppolygons AS SELECT
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Analiza rastrów
--PRZYKŁAD 1 - ST_Band
CREATE TABLE osika.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

--PRZYKŁAD 2 - ST_Clip
CREATE TABLE osika.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--PRZYKŁAD 3 - ST_Slope
CREATE TABLE osika.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM osika.paranhos_dem AS a;

--PRZYKŁAD 4 - ST_Reclass
CREATE TABLE osika.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3','32BF',0)
FROM osika.paranhos_slope AS a;

--PRZYKŁAD 5 - ST_SummaryStats
SELECT st_summarystats(a.rast) AS stats FROM osika.paranhos_dem AS a;

--PRZYKŁAD 6 - ST_SummaryStats oraz Union
SELECT st_summarystats(ST_Union(a.rast)) FROM osika.paranhos_dem AS a;

--PRZYKŁAD 7 - ST_SummaryStats z lepszą kontrolą złożonego typu danych
WITH t AS (SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM osika.paranhos_dem AS a)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

--PRZYKŁAD 8 - ST_SummaryStats w połączeniu z GROUP BY
WITH t AS (SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast,b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast) group by b.parish)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

--PRZYKŁAD 9 - ST_Value
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

--Topographic Position Index (TPI)
--PRZYKŁAD 10 - ST_TPI
CREATE TABLE osika.tpi30 AS
SELECT ST_TPI(a.rast,1) AS rast
FROM rasters.dem a;

CREATE INDEX idx_tpi30_rast_gist ON osika.tpi30 USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('osika'::name,'tpi30'::name,'rast'::name);

--Problem do samodzielnego rozwiązania
CREATE TABLE osika.tpi30_porto AS
SELECT ST_TPI(a.rast,1) AS rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ILIKE 'porto';

CREATE INDEX idx_tpi30_porto_rast_gist ON osika.tpi30_porto USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('osika'::name,'tpi30_porto'::name,'rast'::name);

--Algebra map
--PRZYKŁAD 1 - Wyrażenie Algebry Map
CREATE TABLE osika.porto_ndvi AS
WITH r AS (SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast))
SELECT r.rid,ST_MapAlgebra(r.rast, 1,r.rast, 4,
'([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF') AS rast FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON osika.porto_ndvi USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('osika'::name,'porto_ndvi'::name,'rast'::name);

--PRZYKŁAD 2 – Funkcja zwrotna
CREATE OR REPLACE FUNCTION osika.ndvi(
VALUE double precision [] [] [],
pos integer [][],
VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
RETURN (VALUE [2][1][1] - VALUE [1][1][1])/(VALUE [2][1][1] + VALUE[1][1][1]); 
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE osika.porto_ndvi2 AS
WITH r AS (SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' AND ST_Intersects(b.geom,a.rast))
SELECT r.rid,ST_MapAlgebra(r.rast, ARRAY[1,4],'osika.ndvi(double precision[],integer[],text[])'::regprocedure,
'32BF'::text) AS rast FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON osika.porto_ndvi2 USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('osika'::name,'porto_ndvi2'::name,'rast'::name);

--Eksport danych
--PRZYKŁAD 1 - ST_AsTiff
SELECT ST_AsTiff(ST_Union(rast)) FROM osika.porto_ndvi;

--PRZYKŁAD 2 - ST_AsGDALRaster
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE','PREDICTOR=2', 'PZLEVEL=9'])
FROM osika.porto_ndvi;

SELECT ST_GDALDrivers();

--PRZYKŁAD 3 - Zapisywanie danych na dysku za pomocą dużego obiektu (large object, lo)
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE','PREDICTOR=2', 'PZLEVEL=9'])) 
AS loid FROM osika.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'C:\Users\klaud\Desktop\semestr5\bazy_danych_przestrzennych\cw5\myraster.tiff') FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid) FROM tmp_out;

--PRZYKŁAD 4 - Użycie Gdal
gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9
PG:"host=localhost port=5432 dbname=postgis_raster user=postgres
password=postgis schema=osika table=porto_ndvi mode=2" porto_ndvi.tiff

--Publikowanie danych za pomocą MapServer
--PRZYKŁAD 1 - Mapfile
MAP 
NAME 'map'
SIZE 800 650
STATUS ON
EXTENT -58968 145487 30916 206234
UNITS METERS
WEB
METADATA
'wms_title' 'Terrain wms'
'wms_srs' 'EPSG:3763 EPSG:4326 EPSG:3857'
'wms_enable_request' '*'
'wms_onlineresource'
'http://54.37.13.53/mapservices/srtm'
END
END
PROJECTION
'init=epsg:3763'
END
LAYER
NAME srtm
TYPE raster
STATUS OFF
DATA "PG:host=localhost port=5432 dbname='postgis_raster'
user='postgres' password='postgis' schema='rasters' table='dem' mode='2'"
PROCESSING "SCALE=AUTO"
PROCESSING "NODATA=-32767"
OFFSITE 0 0 0
METADATA
'wms_title' 'srtm'
END
END
END