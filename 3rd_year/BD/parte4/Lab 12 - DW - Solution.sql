
-- 1.	Apresente uma consulta para apurar o consumo médio de todo o campus por dia da semana.
-- Quais os dias da semana em que se regista maior e/ou menor consumo?

-- select * from date_dimension;

select week_day_name, avg(reading)
from meter_readings natural join date_dimension
group by week_day_name;

-- 2. Apresente uma consulta que permita apurar o consumo médio por edifício e por semana
-- durante as três últimas semanas do ano.

select building_name, week_number, avg(reading)
from meter_readings 
	natural join date_dimension 
	natural join building_dimension
where week_number >= 50
group by building_name, week_number
order by building_name, week_number;

-- 3. Efectue o 'ROLLUP' a partir do resultado da alínea anterior, agrupando
-- agora apenas por ‘week_number’. Pode verificar que o consumo vai caindo
-- nas últimas semanas de Dezembro.

-- ROLLUP lógico
select week_number, avg(reading)
from meter_readings natural join date_dimension
where week_number >= 50
group by week_number
order by week_number;

-- ou GROUP BY ROLLUP 

select 
	coalesce(building_name, 'ALL BUILDINGS'),
   	coalesce(cast(week_number as varchar), 'ALL WEEKS'),
   	consumption
from (
	select building_name, week_number, avg(reading) as consumption
	from meter_readings 
		natural join date_dimension 
		natural join building_dimension
	where week_number >= 50
	group by building_name, week_number
	UNION
	select null, week_number, avg(reading) as consumption
	from meter_readings 
		natural join date_dimension
	where week_number >= 50
	group by week_number
	UNION
	select null, null, avg(reading) as consumption
	from meter_readings 
		natural join date_dimension
	where week_number >= 50
) T
order by building_name, week_number;

SELECT building_name, week_number, AVG(reading)
FROM meter_readings
    NATURAL JOIN building_dimension
    NATURAL JOIN date_dimension
GROUP BY ROLLUP (building_name, week_number)


-- 4. Apure que edifícios são os maiores consumidores de energia,
-- calculando o consumo médio por edifício e ordenando o resultado.

select building_name, avg(reading)
from meter_readings natural join building_dimension
group by building_name
order by  avg(reading) desc;

-- 5. Efectue o ‘DRILL DOWN’ dos resultados da alínea anterior por dia da semana (week_day_name)
-- para perceber em que dias da semana é que os maiores consumidores consomem mais energia.
select building_name, week_day_name, avg(reading)
from meter_readings 
	natural join date_dimension 
	natural join building_dimension
group by building_name, week_day_name
order by building_name, avg(reading) desc;

-- 6. Efectue o ‘DRILL DOWN’ dos resultados da alínea 4 por período horário (day_period)
-- para perceber em que períodos horários é que os edificios maiores consumidores consomem
-- mais energia
select building_name, day_period, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension
group by building_name, day_period
order by building_name, day_period, avg(reading) desc;

-- 7. Para analisar a distribuição do consumo médio por edificio, por periodo horário
-- e por hora, apresente agora os resultados do consumo médio por edifício efectuando
-- um ‘ROLLUP’ sequencial sobre os campos day_period e hour_of_day.
-- Utilize a cláusula WITH ROLLUP do MySQL.

select building_name, day_period, hour_of_day, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension
group by rollup (building_name, day_period, hour_of_day)
order by building_name, day_period, hour_of_day, avg(reading) desc;

-- ou com grouping sets
select building_name, day_period, hour_of_day, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension
group by grouping sets ((building_name, day_period, hour_of_day),
    (building_name, day_period),
    (building_name),
    ())
order by building_name, day_period, hour_of_day, avg(reading) desc;

-- ou só com UNION (só este funciona no db.ist.utl.pt)
select building_name, day_period, hour_of_day, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension
group by  building_name, day_period, hour_of_day
UNION
select building_name, day_period, null, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension
group by  building_name, day_period
UNION
select building_name, null, null, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension
group by  building_name
UNION
select null, null, null, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension;

-- 8. Crie uma tabela results com os resultados da alínea anterior
drop table if exists results;
CREATE TABLE if not exists results(
building_name VARCHAR(20),
day_period VARCHAR(20),
hour_of_day INTEGER,
avg_reading DOUBLE PRECISION);

-- se postgres superior ou igual a 9.5
INSERT INTO results
select building_name, day_period, hour_of_day, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension
group by rollup (building_name, day_period, hour_of_day)
order by building_name, day_period, hour_of_day, avg(reading) desc;

-- com o Postgres do IST
INSERT INTO results
select building_name, day_period, hour_of_day, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension
group by  building_name, day_period, hour_of_day
UNION
select building_name, day_period, null, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension
group by  building_name, day_period
UNION
select building_name, null, null, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension
group by  building_name
UNION
select null, null, null, avg(reading)
from meter_readings 
	natural join building_dimension 
	natural join time_dimension;



-- 9. Utilize a tabela results para determinar quais os períodos que apresentam
-- um consumo superior à média dos consumos de todos os edifícios.
-- Sugestão: Uma vez que as médias se encontram já pré-calculadas, utilize IS NULL e
-- IS NOT NULL para obter os resultados.


select day_period
from results
where hour_of_day is null
  and building_name is not null
  and day_period is not null
group by day_period
having avg(avg_reading) >= ALL
    (select avg_reading
    from results
    where building_name is null);


-- 10.  Tendo por base o operador CUBE, apresente a consulta em
--  posgres tendo como vértices building_name, day_period, hour_of_day.

select building_name, day_period, hour_of_day, avg(reading)
from meter_readings natural join building_dimension natural join time_dimension
group by cube (building_name, day_period, hour_of_day)
order by building_name, day_period, hour_of_day, avg(reading) desc;

-- 11. Recorrendo ao operador UNION e ROLLUP, apresente a consulta equivalente à
-- realizada na questão anterior sem recorrer ao operador CUBE.
-- Exercicio removido

SELECT building_name, day_period, hour_of_day, AVG(reading)
FROM meter_readings
    NATURAL JOIN building_dimension
    NATURAL JOIN time_dimension
GROUP BY ROLLUP (building_name, day_period, hour_of_day)
UNION
SELECT building_name, day_period, hour_of_day, AVG(reading)
FROM meter_readings
    NATURAL JOIN building_dimension
    NATURAL JOIN time_dimension
GROUP BY ROLLUP (day_period, hour_of_day, building_name)
UNION
SELECT building_name, day_period, hour_of_day, AVG(reading)
FROM meter_readings
    NATURAL JOIN building_dimension
    NATURAL JOIN time_dimension
GROUP BY ROLLUP (hour_of_day, building_name, day_period);

