/* 1. */
select week_day_name, avg(reading) as average_reading
from meter_readings natural join date_dimension
group by week_day_name, week_day_number
order by week_day_number;

/* 2. */
select building_name, week_number, avg(reading)
from
    building_dimension natural join
    meter_readings natural join
    date_dimension
where week_number between 50 and 52
group by building_name, week_number
order by building_name;

/* 3. */
select
    coalesce(building_name, 'All Buildings'),
    coalesce(cast(week_number as varchar), 'All Weeks'),
    avg
from (
    select building_name, week_number, avg(reading)
    from
        building_dimension natural join
        meter_readings natural join
        date_dimension
    where week_number between 50 and 52
    group by building_name, week_number
    union
    select null, week_number, avg(reading)
    from
        meter_readings natural join
        date_dimension
    where week_number between 50 and 52
    group by week_number
    union
    select null, null, avg(reading)
    from
        meter_readings natural join
        date_dimension
    where week_number between 50 and 52
) as S
order by building_name, week_number;