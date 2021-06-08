/* ------------------------------------------------------------------ */
/*                       BASES DE DADOS 2019/20                       */
/*                          PROJETO, PARTE 3                          */
/*                            queries.sql                             */
/*                                                                    */
/*                             GRUPO TP20                             */
/*                        JOANA MENDONCA, 83597                       */
/*                        GONCALO GUERRA, 83899                       */
/*                        FILIPE COLACO, 84715                        */
/* ------------------------------------------------------------------ */

/* number 1 */
with num_anomalias_utilizador as (
    select nome, count(anomalia_id)
    from
        incidencia natural join (
            select item_id, latitude, longitude
            from item
        ) as item2 natural join
        local_publico
    group by nome
),

maximum_nau as (
    select max(count) as count
    from num_anomalias_utilizador
)

select nome, count
from num_anomalias_utilizador natural join maximum_nau;

/* number 2 */
with num_anomalias_utilizador as (
    select incidencia_email, count(incidencia_email)
    from (
        select anomalia_id, incidencia_email, type, ts
        from
            anomalia natural join
            incidencia natural join
            utilizador
        where
            tem_anomalia_redacao = FALSE and
            type = 'R' and
            ts between '2019-01-01 00:00:00' and '2019-06-30 23:59:59'
    ) as an2
group by incidencia_email),

maximum_nau as (
    select max(count) as count
    from num_anomalias_utilizador
)

select incidencia_email, count
from num_anomalias_utilizador natural join maximum_nau;

/* number 3 */
select incidencia_email
from
    anomalia natural join
    incidencia natural join
    item
where
    ts between '2019-01-01 00:00:00' and '2019-12-31 23:59:59' and
    latitude > 39.336775
group by incidencia_email;

/* number 4 */
select incidencia_email
from 
    incidencia natural join
    correcao natural join
    proposta_de_correcao natural join (
        select anomalia_id, ts
        from anomalia
        where extract(year from ts) = extract(year from now())
    ) as a1 natural join (
        select item_id, latitude
        from item
        where latitude < 39.336775
    ) as a2
where pdc_email != incidencia_email
group by incidencia_email;