

/* insert functions */
create or replace function insertUtilizadores()
    returns trigger as
$BODY$
begin
    for t_row in (select * from utilizador) loop
    	insert into d_utilizador values (t_row.email, t_row.type);
    end loop;
end;
$BODY$
LANGUAGE plpgsql;

create or replace function insertLocais()
    returns trigger as
$BODY$
begin
    for t_row in (select * from local_publico) loop
    	insert into d_local values (t_row.latitude, t_row.longitude, t_row.nome);
    end loop;
end;
$BODY$
LANGUAGE plpgsql;