--zadanie1
CREATE DATABASE s304190;

--zadanie2
CREATE SCHEMA firma;

--zadanie3
CREATE ROLE ksiegowosc;
GRANT CONNECT ON DATABASE s304190 TO ksiegowosc;
GRANT USAGE ON SCHEMA firma TO ksiegowosc;  
GRANT SELECT ON ALL TABLES IN SCHEMA firma TO ksiegowosc;

--zadanie4
--a
CREATE TABLE firma.pracownicy(ID_Pracownika VARCHAR(3) NOT NULL, Imie VARCHAR(20), Nazwisko VARCHAR(20), Adres VARCHAR(100), Telefon VARCHAR(20));
CREATE TABLE firma.godziny(ID_Godziny VARCHAR(3) NOT NULL, Data DATE, Liczba_Godzin INT, ID_Pracownika VARCHAR(3));
CREATE TABLE firma.pensja_stanowisko(ID_Pensji VARCHAR(3) NOT NULL, Stanowisko VARCHAR(30), Kwota INT);
CREATE TABLE firma.premia(ID_Premii VARCHAR(4) NOT NULL, Rodzaj VARCHAR(40), Kwota INT);
CREATE TABLE firma.wynagrodzenie(ID_Wynagrodzenia VARCHAR(3) NOT NULL, Data DATE, ID_Pracownika VARCHAR(3), ID_Godziny VARCHAR(3), ID_Pensji VARCHAR(3), ID_Premii VARCHAR(4));

--b
ALTER TABLE firma.pracownicy ADD PRIMARY KEY (ID_Pracownika);
ALTER TABLE firma.godziny ADD PRIMARY KEY (ID_Godziny);
ALTER TABLE firma.pensja_stanowisko ADD PRIMARY KEY (ID_Pensji);
ALTER TABLE firma.premia ADD PRIMARY KEY (ID_Premii);
ALTER TABLE firma.wynagrodzenie ADD PRIMARY KEY (ID_Wynagrodzenia);

--c
ALTER TABLE firma.godziny ADD FOREIGN KEY (ID_Pracownika) REFERENCES firma.pracownicy(ID_Pracownika);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (ID_Pracownika) REFERENCES firma.pracownicy(ID_Pracownika);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (ID_Godziny) REFERENCES firma.godziny(ID_Godziny);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (ID_Pensji) REFERENCES firma.pensja_stanowisko(ID_Pensji);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (ID_Premii) REFERENCES firma.premia(ID_Premii);

--e
COMMENT ON TABLE firma.pracownicy IS 'Tabela zawierająca dane wszystkich pracowników firmy.';
COMMENT ON TABLE firma.godziny IS 'Tabela zawierająca godziny pracy wszystkich pracowników firmy. Nadgodziny - powyżej 160h.';
COMMENT ON TABLE firma.pensja_stanowisko IS 'Tabela zawierająca pensję oraz stanowiska wszystkich pracowników firmy.';
COMMENT ON TABLE firma.premia IS 'Tabela zawierająca kwotę oraz rodzaj premii wszystkich pracowników firmy.';
COMMENT ON TABLE firma.wynagrodzenie IS 'Tabela zawierająca wynagrodzenia wszystkich pracowników firmy.';

--zadanie 5
--a
ALTER TABLE firma.godziny ADD miesiac INT;
ALTER TABLE firma.godziny ADD tydzien INT;

--b
ALTER TABLE firma.wynagrodzenie ALTER COLUMN Data SET DATA TYPE VARCHAR(20);

--
INSERT INTO firma.pracownicy VALUES(1, 'Adam', 'Nowak', 'Krakowska 20', '783927483');
INSERT INTO firma.pracownicy VALUES(2, 'Jan', 'Kowalski', 'Brzozowa 25', '927384987');
INSERT INTO firma.pracownicy VALUES(3, 'Monika', 'Nowakowska', 'Lipowa 200', '687898123');
INSERT INTO firma.pracownicy VALUES(4, 'Julia', 'Adamska', 'Słoneczna 44', '576879870');
INSERT INTO firma.pracownicy VALUES(5, 'Maria', 'Konarska', 'Deszczowa 3', '567234534');
INSERT INTO firma.pracownicy VALUES(6, 'Andrzej', 'Mazur', 'Szkolna 339', '510029370');
INSERT INTO firma.pracownicy VALUES(7, 'Paweł', 'Grabowski', 'Akacjowa 14', '989172830');
INSERT INTO firma.pracownicy VALUES(8, 'Anna', 'Pawłowska', 'Cicha 30', '718239283');
INSERT INTO firma.pracownicy VALUES(9, 'Karol', 'Kozłowski', 'Szeroka 67', '627384978');
INSERT INTO firma.pracownicy VALUES(10, 'Patrycja', 'Kaczmarek', 'Wysoka 50', '593821600');

INSERT INTO firma.godziny VALUES('G1', '15.05.2020', 154, 1, (SELECT DATE_PART ('month', TIMESTAMP '15.05.2020')), (SELECT DATE_PART ('week', TIMESTAMP '15.05.2020')));
INSERT INTO firma.godziny VALUES('G2', '16.05.2020', 139, 3, (SELECT DATE_PART ('month', TIMESTAMP '16.05.2020')), (SELECT DATE_PART ('week', TIMESTAMP '16.05.2020')));
INSERT INTO firma.godziny VALUES('G3', '17.05.2020', 145, 6, (SELECT DATE_PART ('month', TIMESTAMP '17.05.2020')), (SELECT DATE_PART ('week', TIMESTAMP '17.05.2020')));
INSERT INTO firma.godziny VALUES('G4', '25.05.2020', 85, 8, (SELECT DATE_PART ('month', TIMESTAMP '25.05.2020')), (SELECT DATE_PART ('week', TIMESTAMP '25.05.2020')));
INSERT INTO firma.godziny VALUES('G5', '20.05.2020', 92, 2, (SELECT DATE_PART ('month', TIMESTAMP '20.05.2020')), (SELECT DATE_PART ('week', TIMESTAMP '20.05.2020')));
INSERT INTO firma.godziny VALUES('G6', '14.05.2020', 74, 4, (SELECT DATE_PART ('month', TIMESTAMP '14.05.2020')), (SELECT DATE_PART ('week', TIMESTAMP '14.05.2020')));
INSERT INTO firma.godziny VALUES('G7', '18.05.2020', 121, 5, (SELECT DATE_PART ('month', TIMESTAMP '18.05.2020')), (SELECT DATE_PART ('week', TIMESTAMP '18.05.2020')));
INSERT INTO firma.godziny VALUES('G8', '19.05.2020', 161, 9, (SELECT DATE_PART ('month', TIMESTAMP '19.05.2020')), (SELECT DATE_PART ('week', TIMESTAMP '19.05.2020')));
INSERT INTO firma.godziny VALUES('G9', '15.05.2020', 168, 7, (SELECT DATE_PART ('month', TIMESTAMP '15.05.2020')), (SELECT DATE_PART ('week', TIMESTAMP '15.05.2020')));
INSERT INTO firma.godziny VALUES('G10', '24.05.2020', 110, 10, (SELECT DATE_PART ('month', TIMESTAMP '24.05.2020')), (SELECT DATE_PART ('week', TIMESTAMP '24.05.2020')));

INSERT INTO firma.pensja_stanowisko VALUES('P1', 'Księgowy', 2800.00);
INSERT INTO firma.pensja_stanowisko VALUES('P2', 'Dyrektor generalny', 8500.00);
INSERT INTO firma.pensja_stanowisko VALUES('P3', 'Administrator baz danych', 4500.00);
INSERT INTO firma.pensja_stanowisko VALUES('P4', 'Recepcjonistka', 2500.00);
INSERT INTO firma.pensja_stanowisko VALUES('P5', 'Księgowy', 3000.00);
INSERT INTO firma.pensja_stanowisko VALUES('P6', 'Kierownik działu marketingu', 3800.00);
INSERT INTO firma.pensja_stanowisko VALUES('P7', 'Księgowy', 2900.00);
INSERT INTO firma.pensja_stanowisko VALUES('P8', 'Sprzątaczka', 900.00);
INSERT INTO firma.pensja_stanowisko VALUES('P9', 'Konsultant call center', 2700.00);
INSERT INTO firma.pensja_stanowisko VALUES('P10', 'Sekretarka', 2800.00);

INSERT INTO firma.premia VALUES('PR1', 'Premia indywidualna', 500.00);
INSERT INTO firma.premia VALUES('PR2', 'Premia zadaniowa', 700.00);
INSERT INTO firma.premia VALUES('PR3', 'Premia uznaniowa', 600.00);
INSERT INTO firma.premia VALUES('PR4', 'Premia świąteczna', 350.00);
INSERT INTO firma.premia VALUES('PR5', 'Premia motywacyjna', 400.00);
INSERT INTO firma.premia VALUES('PR6', 'Premia regulaminowa', 500.00);
INSERT INTO firma.premia VALUES('PR7', 'Premia dla najlepszego pracownika', 900.00);
INSERT INTO firma.premia VALUES('PR8', 'Premia kwartalna', 500.00);
INSERT INTO firma.premia VALUES('PR9', 'Premia zespołowa', 300.00);
INSERT INTO firma.premia VALUES('PR10', NULL, 0);

INSERT INTO firma.wynagrodzenie VALUES('W1', '28.05.2020', 1, 'G1', 'P1', 'PR1');
INSERT INTO firma.wynagrodzenie VALUES('W2', '28.05.2020', 6, 'G3', 'P4', 'PR6');
INSERT INTO firma.wynagrodzenie VALUES('W3', '28.05.2020', 2, 'G5', 'P2', 'PR7');
INSERT INTO firma.wynagrodzenie VALUES('W4', '27.05.2020', 7, 'G9', 'P9', 'PR10');
INSERT INTO firma.wynagrodzenie VALUES('W5', '28.05.2020', 10, 'G10', 'P10', 'PR9');
INSERT INTO firma.wynagrodzenie VALUES('W6', '27.05.2020', 3, 'G2', 'P7', 'PR3');
INSERT INTO firma.wynagrodzenie VALUES('W7', '26.05.2020', 8, 'G4', 'P8', 'PR2');
INSERT INTO firma.wynagrodzenie VALUES('W8', '28.05.2020', 9, 'G8', 'P3', 'PR4');
INSERT INTO firma.wynagrodzenie VALUES('W9', '28.05.2020', 4, 'G6', 'P5', 'PR5');
INSERT INTO firma.wynagrodzenie VALUES('W10', '27.05.2020', 5, 'G7', 'P6', 'PR8');

--zadanie 6
--a
SELECT ID_Pracownika, Nazwisko FROM firma.pracownicy;

--b
SELECT ID_Pracownika, kwota FROM firma.wynagrodzenie, firma.pensja_stanowisko
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji 
AND firma.pensja_stanowisko.kwota > 1000

--c
SELECT ID_Pracownika FROM firma.wynagrodzenie, firma.pensja_stanowisko, firma.premia 
WHERE firma.wynagrodzenie.id_premii = firma.premia.id_premii 
AND firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji 
AND firma.premia.kwota = 0 AND firma.pensja_stanowisko.kwota > 2000;

--d
SELECT * FROM firma.pracownicy WHERE Imie LIKE 'J%';

--e
SELECT * FROM firma.pracownicy WHERE Nazwisko LIKE '%n%' 
OR Nazwisko LIKE '%n' OR Nazwisko LIKE 'N%' AND Imie LIKE '%a';

--f
SELECT Imie, Nazwisko, (liczba_godzin - 160) AS nadgodziny FROM firma.pracownicy, firma.godziny 
WHERE firma.pracownicy.id_pracownika = firma.godziny.id_pracownika 
AND firma.godziny.liczba_godzin > 160;

--g
SELECT Imie, Nazwisko FROM firma.pracownicy, firma.wynagrodzenie, firma.pensja_stanowisko
WHERE firma.pracownicy.id_pracownika = firma.wynagrodzenie.id_pracownika 
AND firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji 
AND firma.pensja_stanowisko.kwota > 1500 AND firma.pensja_stanowisko.kwota < 3000;

--h
SELECT imie, nazwisko FROM firma.wynagrodzenie, firma.pracownicy, firma.godziny, firma.premia
WHERE firma.wynagrodzenie.id_pracownika = firma.pracownicy.id_pracownika
AND firma.wynagrodzenie.id_premii = firma.premia.id_premii  
AND firma.wynagrodzenie.id_godziny = firma.godziny.id_godziny
AND firma.premia.kwota = 0 AND firma.godziny.liczba_godzin > 160;

--zadanie 7
--a
SELECT imie, nazwisko, firma.pensja_stanowisko.kwota FROM firma.pracownicy, firma.wynagrodzenie, firma.pensja_stanowisko
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji 
AND firma.pracownicy.id_pracownika = firma.wynagrodzenie.id_pracownika ORDER BY Kwota DESC

--b
SELECT imie, nazwisko, firma.pensja_stanowisko.kwota AS pensja_stanowisko, firma.premia.kwota AS premia
FROM firma.pracownicy, firma.wynagrodzenie, firma.pensja_stanowisko, firma.premia 
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji 
AND firma.wynagrodzenie.id_premii = firma.premia.id_premii 
AND firma.wynagrodzenie.id_pracownika = firma.pracownicy.id_pracownika
ORDER BY firma.pensja_stanowisko.kwota DESC, firma.premia.kwota DESC;

--c
SELECT COUNT(Stanowisko) AS Liczba_Pracownikow, Stanowisko FROM firma.pensja_stanowisko GROUP BY Stanowisko;

--d
SELECT AVG(Kwota) AS Srednia_Płaca, MIN(Kwota), MAX(Kwota) FROM firma.pensja_stanowisko 
WHERE Stanowisko LIKE 'Księgowy';

--e
SELECT SUM(pensja_stanowisko.kwota) + SUM(premia.kwota) AS Suma_Wynagrodzeń FROM firma.pensja_stanowisko, firma.premia;

--f
SELECT Stanowisko, SUM(pensja_stanowisko.kwota) + SUM(premia.kwota) AS wynagrodzenie 
FROM firma.wynagrodzenie, firma.pensja_stanowisko, firma.premia
WHERE firma.wynagrodzenie.id_premii = firma.premia.id_premii
AND firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji
GROUP BY Stanowisko;

--g
SELECT COUNT(Rodzaj) AS Liczba_Premii, Stanowisko
FROM firma.premia, firma.wynagrodzenie, firma.pensja_stanowisko
WHERE wynagrodzenie.id_premii = premia.id_premii 
AND wynagrodzenie.id_pensji = pensja_stanowisko.id_pensji GROUP BY Stanowisko;

--h
DELETE FROM firma.wynagrodzenie USING firma.pensja_stanowisko 
WHERE firma.pensja_stanowisko.id_pensji = firma.wynagrodzenie.id_pensji 
AND firma.pensja_stanowisko.kwota < 1200;

--zadanie 8
--a
UPDATE firma.pracownicy SET Telefon =  '(+48)' || Telefon;

--b
UPDATE firma.pracownicy SET Telefon = SUBSTRING(firma.pracownicy.telefon, 1, 8) || '-' || SUBSTRING(firma.pracownicy.telefon, 9, 3) || '-' || SUBSTRING(firma.pracownicy.telefon, 12, 3);

--c
SELECT ID_Pracownika, Imie, UPPER(Nazwisko) AS Nazwisko, Adres, Telefon 
FROM firma.pracownicy ORDER BY LENGTH(Nazwisko) DESC LIMIT 1;

--d
ALTER TABLE firma.pensja_stanowisko ALTER COLUMN kwota TYPE VARCHAR(10);
SELECT firma.pracownicy.*, MD5(firma.pensja_stanowisko.kwota) AS pensja_stanowisko_md5 FROM firma.pracownicy
JOIN firma.wynagrodzenie ON firma.pracownicy.id_pracownika = firma.wynagrodzenie.id_pracownika 
JOIN firma.pensja_stanowisko ON firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji;

--zadanie 9
ALTER TABLE firma.pensja_stanowisko ALTER COLUMN kwota TYPE INT USING kwota::integer;
SELECT CONCAT('Pracownik ', firma.pracownicy.imie, ' ', firma.pracownicy.nazwisko,
', w dniu ', firma.godziny.data, ' otrzymał pensję całkowitą na kwotę ',
(firma.pensja_stanowisko.kwota + firma.premia.kwota), 'zł, gdzie wynagrodzenie zasadnicze wynosilo: ',
firma.pensja_stanowisko.kwota, 'zł, premia:', firma.premia.kwota, 'zł, nadgodziny: ',(firma.godziny.liczba_godzin - 160)) AS zapytanie
FROM firma.pracownicy, firma.godziny, firma.pensja_stanowisko, firma.premia, firma.wynagrodzenie
WHERE firma.pracownicy.id_pracownika = firma.wynagrodzenie.id_pracownika
AND firma.pensja_stanowisko.id_pensji = firma.wynagrodzenie.id_pensji
AND firma.premia.id_premii = firma.wynagrodzenie.id_premii
AND firma.godziny.id_godziny = firma.wynagrodzenie.id_godziny;
