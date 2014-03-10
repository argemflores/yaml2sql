-- DROP TRIGGER add_variable_column ON master."variable";
-- DROP FUNCTION public.add_variable_column();

create or replace function "master"."add_variable_column"() returns trigger as $add_var_col$
declare
    column_name varchar;
    data_type varchar;
    not_null varchar;
    
    add_column varchar;
begin
    if (upper(new."type") = 'METADATA' or upper(new."type") = 'OBSERVATION') then
        -- column name
        if (new."abbrev" is null or trim(new.abbrev) = '') then
            column_name := lower(new."name");
        else
            column_name := lower(new."abbrev");
        end if;
        
        -- data type
        if (new."data_type" is null or trim(new."data_type") = '') then
            data_type := 'varchar';
        else
            data_type := lower(new."data_type");
        end if;
        
        -- not null
        not_null := '';
        if (new."not_null" = true) then
            not_null := 'not null';
        end if;
        
        add_column := 'add column ' || column_name || ' ' || data_type || ' ' || not_null;
        
        -- add column to warehouse.entry
        execute
            'alter table "warehouse"."entry" ' || add_column;
        
        -- add column to warehouse.plot
        execute
            'alter table "warehouse"."plot" ' || add_column;
    end if;
    
    return new;
end;
$add_var_col$ language plpgsql;

create trigger "add_variable_column"
    after insert on "master"."variable"
    for each row execute procedure "master"."add_variable_column"();
