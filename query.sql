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

            insert into
                master.property (
                    abbrev,
                    name,
                    description
                )
            select
                lower(replace(trim(var."name"), ' ', '_')) abbrev,
                lower(trim(var."name")) "name",
                (
                    select
                        description
                    from
                        import.variable
                    where
                        id = id_arr[1]
                ) description
            from (
                select
                    lower(trim(iv."name")) "name",
                    count(iv.id) id_count,
                    array_agg(iv.id) id_arr
                from
                    import.variable iv
                group by
                    lower(trim(iv."name"))
                order by
                    lower(trim(iv."name")) asc,
                    count(iv.id) desc
            ) var
            ;

            insert into
                master.method (
                    abbrev,
                    name,
                    description
                )
            select
                lower(replace(trim(var."name"), ' ', '_')) || '_method_'
                    || row_number() over (partition by "name") abbrev,
                trim(var."name") "name",
                var.method description
            from (
                select
                    trim(iv.method) method,
                    lower(trim(iv."name")) "name"
                from
                    import.variable iv
                order by
                    trim(iv.method) asc
            ) var
            ;

            insert into
                master.scale (
                    abbrev,
                    name,
                    description,
                    unit,
                    type,
                    level
                )
            select
                lower(replace(trim(var."name"), ' ', '_')) || '_scale_'
                    || row_number() over (partition by "name") abbrev,
                trim(var."name") "name",
                var.scale description,
                var.unit,
                var.type,
                var.level
            from (
                select
                    trim(iv.scale) scale,
                    lower(trim(iv.name)) "name",
                    trim(iv.scale_unit) unit,
                    trim(iv.scale_type) "type",
                    trim(iv.scale_level) "level"
                from
                    import.variable iv
                order by
                    trim(iv.scale) asc
            ) var
            ;

            select
                *
            from
                master.property mp, (
                    select
                        lower(replace(
                            case
                                when iv.abbrev is null
                                    or trim(iv.abbrev) = '' then
                                    iv.name
                                else
                                    iv.abbrev
                            end, ' ', '_'
                        )) abbrev
                    from
                        import.variable iv
                    order by
                        lower(trim(iv."name")) asc
                ) iv
            where
                mp.abbrev = iv.abbrev
            ;


            insert into master.variable (
                abbrev,
                name,
                data_type,
                not_null,
                type,
                status,
                display_name,
                ontology_reference,
                bibliographical_reference,
                property_id,
                method_id,
                scale_id
            )
            select
                (
                    case
                        when var.abbrev is null then
                            var.name || '_' || row_number() over (partition by lower(trim(var."name")))
                        when (
                            select
                                count(iv.id)
                            from
                                import.variable iv
                            where
                                lower(trim(iv.abbrev)) = lower(trim(var.abbrev))
                        ) >= 2 then
                            -- var.abbrev || '_' || row_number() over (partition by lower(trim(var."name")))
                            var.abbrev || '_' || (trunc(random() * 10) + 1) || (trunc(random() * 10) + 1)
                        else
                            var.abbrev
                    end
                ) abbrev,
                var.name,
                -- var.description,
                (
                    case
                        when var.data_type is null then
                            'varchar'
                        else
                            var.data_type
                    end
                ) data_type,
                var.not_null::bool,
                var.type,
                var.status,
                (
                    case
                        when var.display_name is null then
                            initcap(var.name)
                        else
                            initcap(var.display_name)
                    end
                ) display_name,
                var.ontology_reference,
                var.bibliographical_reference,
                
                var.property_id,
                var.method_id,
                var.scale_id
            from (
                select
                    iv.abbrev,
                    iv.name,
                    iv.description,
                    iv.data_type,
                    iv.not_null,
                    iv.type,
                    iv.status,
                    iv.display_name,
                    iv.ontology_reference,
                    iv.bibliographical_reference,
                    
                    (
                        select
                            -- mp.name
                            mp.id
                        from
                            master.property mp
                        where
                            mp.name = iv.name
                    ) property_id,
                    (
                        select
                            -- mm.name
                            mm.id
                        from
                            master.method mm
                        where
                            mm.name = iv.name || ' ' || num
                            -- and trim(mm.description) = iv.method
                    ) method_id,
                    (
                        select
                            -- ms.name
                            ms.id
                        from
                            master.scale ms
                        where
                            ms.name = iv.name || ' ' || num
                            -- and ms.description = iv.scale
                    ) scale_id
                from (
                    select
                        row_number() over (partition by lower(trim("name"))) num,
                        
                        lower(trim(iv.abbrev)) "abbrev",
                        lower(trim(iv.name)) "name",
                        trim(iv.description) description,
                        lower(trim(iv.data_type)) data_type,
                        lower(trim(iv.not_null)) not_null,
                        lower(trim(iv.type)) "type",
                        lower(trim(iv.status)) status,
                        trim(iv.display_name) display_name,
                        trim(iv.ontology_reference) ontology_reference,
                        trim(iv.bibliographical_reference) bibliographical_reference,
                        
                        trim(iv.method) "method",
                        trim(iv.scale) "scale"
                    from
                        import.variable iv
                ) iv
                order by
                    property_id,
                    method_id,
                    scale_id
            ) var
            ;


            insert into master.variable_set (
                abbrev,
                name,
                display_name
            )
            select
                distinct on (
                    iv.variable_set
                )
                iv.variable_set abbrev,
                iv.variable_set "name",
                initcap(iv.variable_set) display_name
            from (
                select
                    lower(trim(iv.variable_set)) variable_set
                from
                    import.variable iv
            ) iv
            where
                iv.variable_set is not null
            ;
            
            insert into master.variable_set_member (
                variable_set_id,
                variable_id,
                order_number
            )
            select
                (
                    select
                        mvs.id
                    from
                        master.variable_set mvs
                    where
                        mvs.name = mv.variable_set
                ) variable_set_id,
                id variable_id,
                row_number() over (partition by mv.variable_set) order_number
            from
                master.variable mv
            where
                mv.variable_set is not null
            ;
            
            
            insert into master.variable (
                abbrev,
                name,
                data_type,
                not_null,
                type,
                status,
                display_name,
                ontology_reference,
                bibliographical_reference,
                property_id,
                method_id,
                scale_id,
                variable_set
            )
            select
                (replace(
                    (
                        case
                            when var.abbrev is null then
                                -- var.name || '_' || substring(var.scale_type from 1 for 3)
                                var.name || '_' || (
                                    case when var.scale_type is null then ''
                                    else substring(var.scale_type from 1 for 3) || '_' end
                                ) || row_number() over (partition by lower(trim(var.name)), substring(var.scale_type from 1 for 3))
                            when (
                                select
                                    count(iv.id)
                                from
                                    import.variable iv
                                where
                                    lower(trim(iv.abbrev)) = lower(trim(var.abbrev))
                            ) >= 2 then
                                -- var.abbrev || '_' || row_number() over (partition by lower(trim(var."name")))
                                -- var.abbrev || '_' || (trunc((random() * 10)::numeric, 2) + 1)
                                var.abbrev || '_' || (
                                    case when var.scale_type is null then ''
                                    else substring(var.scale_type from 1 for 3) || '_' end
                                ) || row_number() over (partition by lower(trim(var.name)), substring(var.scale_type from 1 for 3))
                            else
                                var.abbrev
                        end
                    ),
                ' ', '_')) abbrev,
                var.name,
                -- var.description,
                (
                    case
                        when var.data_type is null then
                            'varchar'
                        else
                            var.data_type
                    end
                ) data_type,
                var.not_null::bool,
                var.type,
                var.status,
                (
                    case
                        when var.display_name is null then
                            initcap(var.name)
                        else
                            initcap(var.display_name)
                    end
                ) display_name,
                var.ontology_reference,
                var.bibliographical_reference,
                
                var.property_id,
                var.method_id,
                var.scale_id,
                var.variable_set
            from (
                select
                    iv.abbrev,
                    iv.name,
                    iv.description,
                    iv.data_type,
                    iv.not_null,
                    iv.type,
                    iv.status,
                    iv.display_name,
                    iv.ontology_reference,
                    iv.bibliographical_reference,
                    
                    (
                        select
                            -- mp.name
                            mp.id
                        from
                            master.property mp
                        where
                            mp.name = iv.name
                    ) property_id,
                    (
                        select
                            -- mm.name
                            mm.id
                        from
                            master.method mm
                        where
                            mm.name = iv.name || ' ' || num
                            -- and trim(mm.description) = iv.method
                    ) method_id,
                    (
                        select
                            -- ms.name
                            ms.id
                        from
                            master.scale ms
                        where
                            ms.name = iv.name || ' ' || num
                            -- and ms.description = iv.scale
                    ) scale_id,
                    (
                        select
                            -- ms.name
                            ms.type
                        from
                            master.scale ms
                        where
                            ms.name = iv.name || ' ' || num
                            -- and ms.description = iv.scale
                    ) scale_type,
                    
                    iv.variable_set
                from (
                    select
                        row_number() over (partition by lower(trim("name"))) num,
                        
                        lower(trim(iv.abbrev)) "abbrev",
                        lower(trim(iv.name)) "name",
                        trim(iv.description) description,
                        lower(trim(iv.data_type)) data_type,
                        lower(trim(iv.not_null)) not_null,
                        lower(trim(iv.type)) "type",
                        lower(trim(iv.status)) status,
                        trim(iv.display_name) display_name,
                        trim(iv.ontology_reference) ontology_reference,
                        trim(iv.bibliographical_reference) bibliographical_reference,
                        
                        trim(iv.method) "method",
                        trim(iv.scale) "scale",
                        
                        lower(trim(iv.variable_set)) variable_set
                    from
                        import.variable iv
                ) iv
                order by
                    property_id,
                    method_id,
                    scale_id
            ) var
            ;
