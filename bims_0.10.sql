select pg_terminate_backend(pid) from pg_stat_activity where datname='bims_0.10_dev' and pid <> pg_backend_pid();

-- --------------------------------

drop schema if exists "master" cascade;

drop schema if exists "dictionary" cascade;

drop schema if exists "operational" cascade;

drop schema if exists "warehouse" cascade;

-- --------------------------------

-- create database "bims_0.10_dev"
    -- encoding = 'UTF8'
    -- lc_collate = 'C'
    -- lc_ctype = 'C';

-- --------------------------------

create schema "master";

create table "master"."user" (
    "id" serial not null,
    "email" varchar(64) not null,
    "username" varchar(64) not null,
    "last_name" varchar(32) not null,
    "first_name" varchar(32) not null,
    "middle_name" varchar(32),
    "display_name" varchar(64) not null,
    "status" varchar not null default 'active',
    "salutation" varchar(16),
    "valid_start_date" date,
    "valid_end_date" date,
    "user_type" integer not null,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."user"
  add constraint "user_id_pkey"
  primary key ("id");
alter table "master"."user"
  add constraint "user_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."user"
  add constraint "user_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "user_email_idx"
  on "master"."user"
  using btree ("email");
create unique index "user_username_idx"
  on "master"."user"
  using btree ("username");
create index "user_is_void_idx"
  on "master"."user"
  using btree ("is_void");

-- ----------------

create table "master"."property" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."property"
  add constraint "property_id_pkey"
  primary key ("id");
alter table "master"."property"
  add constraint "property_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."property"
  add constraint "property_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "property_abbrev_idx"
  on "master"."property"
  using btree ("abbrev");
create index "property_is_void_idx"
  on "master"."property"
  using btree ("is_void");

-- ----------------

create table "master"."method" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."method"
  add constraint "method_id_pkey"
  primary key ("id");
alter table "master"."method"
  add constraint "method_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."method"
  add constraint "method_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "method_abbrev_idx"
  on "master"."method"
  using btree ("abbrev");
create index "method_is_void_idx"
  on "master"."method"
  using btree ("is_void");

-- ----------------

create table "master"."scale" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "unit" varchar,
    "type" varchar,
    "level" varchar,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."scale"
  add constraint "scale_id_pkey"
  primary key ("id");
alter table "master"."scale"
  add constraint "scale_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."scale"
  add constraint "scale_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "scale_abbrev_idx"
  on "master"."scale"
  using btree ("abbrev");
create index "scale_is_void_idx"
  on "master"."scale"
  using btree ("is_void");

-- ----------------

create table "master"."scale_value" (
    "id" serial not null,
    "scale_id" integer not null,
    "value" varchar not null,
    "display_name" varchar,
    "description" text,
    "remarks" text,
    "order_number" integer not null default '1',
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."scale_value"
  add constraint "scale_value_scale_id_fkey"
  foreign key ("scale_id") references "master"."scale" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."scale_value"
  add constraint "scale_value_id_pkey"
  primary key ("id");
alter table "master"."scale_value"
  add constraint "scale_value_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."scale_value"
  add constraint "scale_value_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "scale_value_scale_id_idx"
  on "master"."scale_value"
  using btree ("scale_id");
create index "scale_value_is_void_idx"
  on "master"."scale_value"
  using btree ("is_void");

-- ----------------

create table "master"."variable" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "data_type" varchar,
    "not_null" boolean not null default false,
    "type" varchar(32),
    "status" varchar(32),
    "display_name" varchar not null,
    "ontology_reference" varchar,
    "bibliographical_reference" varchar,
    "property_id" integer,
    "method_id" integer,
    "scale_id" integer,
    "variable_set" varchar,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."variable"
  add constraint "variable_property_id_fkey"
  foreign key ("property_id") references "master"."property" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."variable"
  add constraint "variable_method_id_fkey"
  foreign key ("method_id") references "master"."method" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."variable"
  add constraint "variable_scale_id_fkey"
  foreign key ("scale_id") references "master"."scale" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."variable"
  add constraint "variable_id_pkey"
  primary key ("id");
alter table "master"."variable"
  add constraint "variable_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."variable"
  add constraint "variable_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "variable_property_id_idx"
  on "master"."variable"
  using btree ("property_id");
create index "variable_method_id_idx"
  on "master"."variable"
  using btree ("method_id");
create index "variable_scale_id_idx"
  on "master"."variable"
  using btree ("scale_id");
create unique index "variable_abbrev_idx"
  on "master"."variable"
  using btree ("abbrev");
create index "variable_is_void_idx"
  on "master"."variable"
  using btree ("is_void");

-- ----------------

create table "master"."variable_set" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "display_name" varchar not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."variable_set"
  add constraint "variable_set_id_pkey"
  primary key ("id");
alter table "master"."variable_set"
  add constraint "variable_set_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."variable_set"
  add constraint "variable_set_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "variable_set_abbrev_idx"
  on "master"."variable_set"
  using btree ("abbrev");
create index "variable_set_is_void_idx"
  on "master"."variable_set"
  using btree ("is_void");

-- ----------------

create table "master"."variable_set_member" (
    "id" serial not null,
    "variable_set_id" integer not null,
    "variable_id" integer not null,
    "order_number" integer not null default '1',
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."variable_set_member"
  add constraint "variable_set_member_variable_set_id_fkey"
  foreign key ("variable_set_id") references "master"."variable_set" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."variable_set_member"
  add constraint "variable_set_member_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."variable_set_member"
  add constraint "variable_set_member_id_pkey"
  primary key ("id");
alter table "master"."variable_set_member"
  add constraint "variable_set_member_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."variable_set_member"
  add constraint "variable_set_member_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "variable_set_member_is_void_idx"
  on "master"."variable_set_member"
  using btree ("is_void");

-- ----------------

create table "master"."pipeline" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."pipeline"
  add constraint "pipeline_id_pkey"
  primary key ("id");
alter table "master"."pipeline"
  add constraint "pipeline_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."pipeline"
  add constraint "pipeline_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "pipeline_abbrev_idx"
  on "master"."pipeline"
  using btree ("abbrev");
create index "pipeline_is_void_idx"
  on "master"."pipeline"
  using btree ("is_void");

-- ----------------

create table "master"."crosscutting" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."crosscutting"
  add constraint "crosscutting_id_pkey"
  primary key ("id");
alter table "master"."crosscutting"
  add constraint "crosscutting_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."crosscutting"
  add constraint "crosscutting_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "crosscutting_abbrev_idx"
  on "master"."crosscutting"
  using btree ("abbrev");
create index "crosscutting_is_void_idx"
  on "master"."crosscutting"
  using btree ("is_void");

-- ----------------

create table "master"."program" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."program"
  add constraint "program_id_pkey"
  primary key ("id");
alter table "master"."program"
  add constraint "program_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."program"
  add constraint "program_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "program_abbrev_idx"
  on "master"."program"
  using btree ("abbrev");
create index "program_is_void_idx"
  on "master"."program"
  using btree ("is_void");

-- ----------------

create table "master"."place" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."place"
  add constraint "place_id_pkey"
  primary key ("id");
alter table "master"."place"
  add constraint "place_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."place"
  add constraint "place_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "place_abbrev_idx"
  on "master"."place"
  using btree ("abbrev");
create index "place_is_void_idx"
  on "master"."place"
  using btree ("is_void");

-- ----------------

create table "master"."phase" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "order_number" integer not null default '1',
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."phase"
  add constraint "phase_id_pkey"
  primary key ("id");
alter table "master"."phase"
  add constraint "phase_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."phase"
  add constraint "phase_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "phase_abbrev_idx"
  on "master"."phase"
  using btree ("abbrev");
create index "phase_is_void_idx"
  on "master"."phase"
  using btree ("is_void");

-- ----------------

create table "master"."product" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "gid" integer not null,
    "type" varchar not null,
    "authority" varchar not null,
    "generation" integer,
    "iris_preferred_id" varchar,
    "breeding_line_name" varchar,
    "fixed_line_name" varchar,
    "common_name" varchar,
    "cultivar_name" varchar,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."product"
  add constraint "product_id_pkey"
  primary key ("id");
alter table "master"."product"
  add constraint "product_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."product"
  add constraint "product_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "product_abbrev_idx"
  on "master"."product"
  using btree ("abbrev");
create index "product_is_void_idx"
  on "master"."product"
  using btree ("is_void");

-- ----------------

create table "master"."product_metadata" (
    "id" serial not null,
    "variable_id" integer,
    "value" varchar not null,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."product_metadata"
  add constraint "product_metadata_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."product_metadata"
  add constraint "product_metadata_id_pkey"
  primary key ("id");
alter table "master"."product_metadata"
  add constraint "product_metadata_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."product_metadata"
  add constraint "product_metadata_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "product_metadata_is_void_idx"
  on "master"."product_metadata"
  using btree ("is_void");

-- ----------------

create table "master"."season" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."season"
  add constraint "season_id_pkey"
  primary key ("id");
alter table "master"."season"
  add constraint "season_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."season"
  add constraint "season_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "season_abbrev_idx"
  on "master"."season"
  using btree ("abbrev");
create index "season_is_void_idx"
  on "master"."season"
  using btree ("is_void");

-- ----------------

create table "master"."place_season" (
    "id" serial not null,
    "place_id" integer not null,
    "season_id" integer not null,
    "order_number" integer not null default '1',
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."place_season"
  add constraint "place_season_place_id_fkey"
  foreign key ("place_id") references "master"."place" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."place_season"
  add constraint "place_season_season_id_fkey"
  foreign key ("season_id") references "master"."season" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."place_season"
  add constraint "place_season_id_pkey"
  primary key ("id");
alter table "master"."place_season"
  add constraint "place_season_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."place_season"
  add constraint "place_season_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "place_season_place_id_idx"
  on "master"."place_season"
  using btree ("place_id");
create index "place_season_season_id_idx"
  on "master"."place_season"
  using btree ("season_id");

-- ----------------

create table "master"."cross_method" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "master"."cross_method"
  add constraint "cross_method_id_pkey"
  primary key ("id");
alter table "master"."cross_method"
  add constraint "cross_method_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."cross_method"
  add constraint "cross_method_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "cross_method_abbrev_idx"
  on "master"."cross_method"
  using btree ("abbrev");
create index "cross_method_is_void_idx"
  on "master"."cross_method"
  using btree ("is_void");

create view "master"."variable_list" as
select
    mv.abbrev,
    mv.name,
    mv.data_type,
    mv.not_null,
    mv.type,
    mv.status,
    mv.display_name,
    mv.ontology_reference,
    mv.bibliographical_reference,
    mv.property_id,
    mv.method_id,
    mv.scale_id,
    mp.abbrev property_abbrev,
    mp.name property_name,
    mp.description property_description,
    mm.abbrev method_abbrev,
    mm.name method_name,
    mm.description method_description,
    ms.abbrev scale_abbrev,
    ms.name scale_name,
    ms.description scale_description,
    ms.unit scale_unit,
    ms.type scale_type,
    ms.level scale_level
from
    master.variable mv,
    master.property mp,
    master.method mm,
    master.scale ms
where
    mv.property_id = mp.id
    and mv.method_id = mm.id
    and mv.scale_id = ms.id
;

-- --------------------------------

create schema "dictionary";

create table "dictionary"."database" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "comment" text,
    "encoding" varchar not null default 'UTF8',
    "lc_collate" varchar not null default 'C',
    "lc_ctype" varchar not null default 'C',
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."database"
  add constraint "database_id_pkey"
  primary key ("id");
alter table "dictionary"."database"
  add constraint "database_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."database"
  add constraint "database_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "database_abbrev_idx"
  on "dictionary"."database"
  using btree ("abbrev");
create index "database_is_void_idx"
  on "dictionary"."database"
  using btree ("is_void");

-- ----------------

create table "dictionary"."schema" (
    "id" serial not null,
    "database_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "comment" text,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."schema"
  add constraint "schema_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."schema"
  add constraint "schema_id_pkey"
  primary key ("id");
alter table "dictionary"."schema"
  add constraint "schema_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."schema"
  add constraint "schema_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "schema_abbrev_idx"
  on "dictionary"."schema"
  using btree ("abbrev");
create index "schema_is_void_idx"
  on "dictionary"."schema"
  using btree ("is_void");

-- ----------------

create table "dictionary"."table" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "comment" text,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."table"
  add constraint "table_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."table"
  add constraint "table-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."table"
  add constraint "table_id_pkey"
  primary key ("id");
alter table "dictionary"."table"
  add constraint "table_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."table"
  add constraint "table_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "table_abbrev_idx"
  on "dictionary"."table"
  using btree ("abbrev");
create index "table_is_void_idx"
  on "dictionary"."table"
  using btree ("is_void");

-- ----------------

create table "dictionary"."column" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "table_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "data_type" varchar(32) not null,
    "length" varchar(32),
    "not_null" boolean not null default false,
    "default_value" varchar,
    "comment" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."column"
  add constraint "column_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."column"
  add constraint "column-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."column"
  add constraint "column_table_id_fkey"
  foreign key ("table_id") references "dictionary"."table" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."column"
  add constraint "column_id_pkey"
  primary key ("id");
alter table "dictionary"."column"
  add constraint "column_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."column"
  add constraint "column_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "column_abbrev_idx"
  on "dictionary"."column"
  using btree ("abbrev");
create index "column_is_void_idx"
  on "dictionary"."column"
  using btree ("is_void");

-- ----------------

create table "dictionary"."constraint" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "table_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "type" varchar,
    "column_id" integer not null,
    "command" text,
    "foreign_table_id" integer,
    "foreign_column_id" integer,
    "on_delete" varchar not null default 'no action',
    "on_update" varchar not null default 'no action',
    "match_type" varchar not null default 'simple',
    "no_inherit" boolean not null default false,
    "concurrent" boolean not null default false,
    "comment" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."constraint"
  add constraint "constraint_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."constraint"
  add constraint "constraint-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."constraint"
  add constraint "constraint_table_id_fkey"
  foreign key ("table_id") references "dictionary"."table" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."constraint"
  add constraint "constraint-column_id_fkey"
  foreign key ("column_id") references "dictionary"."column" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."constraint"
  add constraint "constraint_id_pkey"
  primary key ("id");
alter table "dictionary"."constraint"
  add constraint "constraint_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."constraint"
  add constraint "constraint_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "constraint_abbrev_idx"
  on "dictionary"."constraint"
  using btree ("abbrev");
create index "constraint_is_void_idx"
  on "dictionary"."constraint"
  using btree ("is_void");

-- ----------------

create table "dictionary"."index" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "table_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "column_id" integer not null,
    "using" varchar,
    "unique" boolean not null default false,
    "concurrent" boolean not null default false,
    "comment" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."index"
  add constraint "index_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."index"
  add constraint "index-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."index"
  add constraint "index_table_id_fkey"
  foreign key ("table_id") references "dictionary"."table" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."index"
  add constraint "index-column_id_fkey"
  foreign key ("column_id") references "dictionary"."column" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."index"
  add constraint "index_id_pkey"
  primary key ("id");
alter table "dictionary"."index"
  add constraint "index_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."index"
  add constraint "index_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "index_abbrev_idx"
  on "dictionary"."index"
  using btree ("abbrev");
create index "index_is_void_idx"
  on "dictionary"."index"
  using btree ("is_void");

-- ----------------

create table "dictionary"."rule" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "event" varchar(16) not null default 'select',
    "execution" varchar(8) not null default 'also',
    "condition" text,
    "command" text,
    "comment" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."rule"
  add constraint "rule_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."rule"
  add constraint "rule-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."rule"
  add constraint "rule_id_pkey"
  primary key ("id");
alter table "dictionary"."rule"
  add constraint "rule_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."rule"
  add constraint "rule_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "rule_abbrev_idx"
  on "dictionary"."rule"
  using btree ("abbrev");
create index "rule_is_void_idx"
  on "dictionary"."rule"
  using btree ("is_void");

-- ----------------

create table "dictionary"."trigger" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "enabled" boolean not null default true,
    "execution" varchar not null default 'before',
    "for_each" varchar not null default 'row',
    "event" varchar default 'insert',
    "function" varchar not null,
    "argument" varchar,
    "condition" varchar,
    "comment" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."trigger"
  add constraint "trigger_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."trigger"
  add constraint "trigger-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."trigger"
  add constraint "trigger_id_pkey"
  primary key ("id");
alter table "dictionary"."trigger"
  add constraint "trigger_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."trigger"
  add constraint "trigger_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "trigger_abbrev_idx"
  on "dictionary"."trigger"
  using btree ("abbrev");
create index "trigger_is_void_idx"
  on "dictionary"."trigger"
  using btree ("is_void");

-- ----------------

create table "dictionary"."view" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "command" text,
    "comment" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."view"
  add constraint "view_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."view"
  add constraint "view-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."view"
  add constraint "view_id_pkey"
  primary key ("id");
alter table "dictionary"."view"
  add constraint "view_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."view"
  add constraint "view_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "view_abbrev_idx"
  on "dictionary"."view"
  using btree ("abbrev");
create index "view_is_void_idx"
  on "dictionary"."view"
  using btree ("is_void");

-- ----------------

create table "dictionary"."sequence" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "value" integer not null default '1',
    "increment" integer not null default '1',
    "maximum_value" integer not null default '2147483647',
    "minimum_value" integer not null default '1',
    "cache" integer not null default '1',
    "cycle" boolean not null default false,
    "comment" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."sequence"
  add constraint "sequence_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."sequence"
  add constraint "sequence-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."sequence"
  add constraint "sequence_id_pkey"
  primary key ("id");
alter table "dictionary"."sequence"
  add constraint "sequence_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."sequence"
  add constraint "sequence_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "sequence_abbrev_idx"
  on "dictionary"."sequence"
  using btree ("abbrev");
create index "sequence_is_void_idx"
  on "dictionary"."sequence"
  using btree ("is_void");

-- ----------------

create table "dictionary"."function" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "cycle" varchar not null default 'single_value',
    "return_type" varchar not null default 'varchar',
    "language" varchar not null default 'plpgsql',
    "strict" boolean not null default false,
    "execution_privilege" varchar not null default 'invoker',
    "stability" varchar not null default 'volatile',
    "comment" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."function"
  add constraint "function_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."function"
  add constraint "function-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."function"
  add constraint "function_id_pkey"
  primary key ("id");
alter table "dictionary"."function"
  add constraint "function_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."function"
  add constraint "function_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "function_abbrev_idx"
  on "dictionary"."function"
  using btree ("abbrev");
create index "function_is_void_idx"
  on "dictionary"."function"
  using btree ("is_void");

-- ----------------

create table "dictionary"."domain" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "data_type" varchar,
    "not_null" boolean not null default false,
    "default_value" varchar,
    "collation" varchar not null default 'pg_catalog.C',
    "comment" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."domain"
  add constraint "domain_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."domain"
  add constraint "domain-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."domain"
  add constraint "domain_id_pkey"
  primary key ("id");
alter table "dictionary"."domain"
  add constraint "domain_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."domain"
  add constraint "domain_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "domain_abbrev_idx"
  on "dictionary"."domain"
  using btree ("abbrev");
create index "domain_is_void_idx"
  on "dictionary"."domain"
  using btree ("is_void");

-- ----------------

create table "dictionary"."aggregate" (
    "id" serial not null,
    "database_id" integer not null,
    "schema_id" integer not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "base_type" varchar not null default 'integer',
    "state_type" varchar not null default 'integer',
    "state_function_id" integer not null,
    "final_function_id" integer,
    "initial_condition" text,
    "comment" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "dictionary"."aggregate"
  add constraint "aggregate_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."aggregate"
  add constraint "aggregate-schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."aggregate"
  add constraint "aggregate_state_function_id_fkey"
  foreign key ("state_function_id") references "dictionary"."function" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."aggregate"
  add constraint "aggregate_final_function_id_fkey"
  foreign key ("final_function_id") references "dictionary"."function" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."aggregate"
  add constraint "aggregate_id_pkey"
  primary key ("id");
alter table "dictionary"."aggregate"
  add constraint "aggregate_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."aggregate"
  add constraint "aggregate_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create unique index "aggregate_abbrev_idx"
  on "dictionary"."aggregate"
  using btree ("abbrev");
create index "aggregate_is_void_idx"
  on "dictionary"."aggregate"
  using btree ("is_void");

-- --------------------------------

create schema "operational";

create table "operational"."study" (
    "id" serial not null,
    "program_id" integer not null,
    "place_id" integer not null,
    "phase_id" integer not null,
    "year" integer not null,
    "season_id" integer not null,
    "sequence_number" integer not null,
    "key" integer not null,
    "name" varchar(128) not null,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."study"
  add constraint "study_program_id_fkey"
  foreign key ("program_id") references "master"."program" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."study"
  add constraint "study_place_id_fkey"
  foreign key ("place_id") references "master"."place" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."study"
  add constraint "study_phase_id_fkey"
  foreign key ("phase_id") references "master"."phase" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."study"
  add constraint "study_season_id_fkey"
  foreign key ("season_id") references "master"."season" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."study"
  add constraint "study_id_pkey"
  primary key ("id");
alter table "operational"."study"
  add constraint "study_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."study"
  add constraint "study_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "study_program_id_idx"
  on "operational"."study"
  using btree ("program_id");
create index "study_place_id_idx"
  on "operational"."study"
  using btree ("place_id");
create index "study_phase_id_idx"
  on "operational"."study"
  using btree ("phase_id");
create index "study_year_idx"
  on "operational"."study"
  using btree ("year");
create index "study_season_id_idx"
  on "operational"."study"
  using btree ("season_id");
create index "study_year_season_id_idx"
  on "operational"."study"
  using btree ("year", "season_id");
create index "study_key_idx"
  on "operational"."study"
  using btree ("key");
create index "study_name_idx"
  on "operational"."study"
  using btree ("name");
create index "study_is_void_idx"
  on "operational"."study"
  using btree ("is_void");

-- ----------------

create table "operational"."study_metadata" (
    "id" serial not null,
    "study_id" integer not null,
    "variable_id" integer not null,
    "value" varchar not null,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."study_metadata"
  add constraint "study_metadata_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."study_metadata"
  add constraint "study_metadata_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."study_metadata"
  add constraint "study_metadata_id_pkey"
  primary key ("id");
alter table "operational"."study_metadata"
  add constraint "study_metadata_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."study_metadata"
  add constraint "study_metadata_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "study_metadata_study_id_idx"
  on "operational"."study_metadata"
  using btree ("study_id");
create index "study_metadata_variable_id_idx"
  on "operational"."study_metadata"
  using btree ("variable_id");
create index "study_metadata_is_void_idx"
  on "operational"."study_metadata"
  using btree ("is_void");

-- ----------------

create table "operational"."entry" (
    "id" serial not null,
    "study_id" integer not null,
    "number" integer not null default '1',
    "key" integer not null,
    "code" varchar,
    "product_id" integer not null,
    "product_gid" integer not null,
    "product_name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."entry"
  add constraint "entry_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry"
  add constraint "entry_product_id_fkey"
  foreign key ("product_id") references "master"."product" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry"
  add constraint "entry_id_pkey"
  primary key ("id");
alter table "operational"."entry"
  add constraint "entry_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry"
  add constraint "entry_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "entry_study_id_idx"
  on "operational"."entry"
  using btree ("study_id");
create index "entry_key_idx"
  on "operational"."entry"
  using btree ("key");
create index "entry_product_id_idx"
  on "operational"."entry"
  using btree ("product_id");
create index "entry_is_void_idx"
  on "operational"."entry"
  using btree ("is_void");

-- ----------------

create table "operational"."entry_metadata" (
    "id" serial not null,
    "study_id" integer not null,
    "entry_id" integer not null,
    "variable_id" integer not null,
    "value" varchar not null,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."entry_metadata"
  add constraint "entry_metadata_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry_metadata"
  add constraint "entry_metadata_entry_id_fkey"
  foreign key ("entry_id") references "operational"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry_metadata"
  add constraint "entry_metadata_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry_metadata"
  add constraint "entry_metadata_id_pkey"
  primary key ("id");
alter table "operational"."entry_metadata"
  add constraint "entry_metadata_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry_metadata"
  add constraint "entry_metadata_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "entry_metadata_study_id_idx"
  on "operational"."entry_metadata"
  using btree ("study_id");
create index "entry_metadata_entry_id_idx"
  on "operational"."entry_metadata"
  using btree ("entry_id");
create index "entry_metadata_variable_id_idx"
  on "operational"."entry_metadata"
  using btree ("variable_id");
create index "entry_metadata_is_void_idx"
  on "operational"."entry_metadata"
  using btree ("is_void");

-- ----------------

create table "operational"."entry_data" (
    "id" serial not null,
    "study_id" integer not null,
    "entry_id" integer not null,
    "variable_id" integer not null,
    "value" varchar not null,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."entry_data"
  add constraint "entry_data_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry_data"
  add constraint "entry_data_entry_id_fkey"
  foreign key ("entry_id") references "operational"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry_data"
  add constraint "entry_data_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry_data"
  add constraint "entry_data_id_pkey"
  primary key ("id");
alter table "operational"."entry_data"
  add constraint "entry_data_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."entry_data"
  add constraint "entry_data_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "entry_data_study_id_idx"
  on "operational"."entry_data"
  using btree ("study_id");
create index "entry_data_entry_id_idx"
  on "operational"."entry_data"
  using btree ("entry_id");
create index "entry_data_variable_id_idx"
  on "operational"."entry_data"
  using btree ("variable_id");
create index "entry_data_is_void_idx"
  on "operational"."entry_data"
  using btree ("is_void");

-- ----------------

create table "operational"."plot" (
    "id" serial not null,
    "study_id" integer not null,
    "entry_id" integer not null,
    "replication_number" integer,
    "key" integer not null,
    "code" varchar,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."plot"
  add constraint "plot_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot"
  add constraint "plot_entry_id_fkey"
  foreign key ("entry_id") references "operational"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot"
  add constraint "plot_id_pkey"
  primary key ("id");
alter table "operational"."plot"
  add constraint "plot_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot"
  add constraint "plot_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "plot_study_id_idx"
  on "operational"."plot"
  using btree ("study_id");
create index "plot_entry_id_idx"
  on "operational"."plot"
  using btree ("entry_id");
create index "plot_key_idx"
  on "operational"."plot"
  using btree ("key");
create index "plot_is_void_idx"
  on "operational"."plot"
  using btree ("is_void");

-- ----------------

create table "operational"."plot_metadata" (
    "id" serial not null,
    "study_id" integer not null,
    "entry_id" integer not null,
    "plot_id" integer not null,
    "variable_id" integer not null,
    "value" varchar not null,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."plot_metadata"
  add constraint "plot_metadata_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot_metadata"
  add constraint "plot_metadata_entry_id_fkey"
  foreign key ("entry_id") references "operational"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot_metadata"
  add constraint "plot_metadata_plot_id_fkey"
  foreign key ("plot_id") references "operational"."plot" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot_metadata"
  add constraint "plot_metadata_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot_metadata"
  add constraint "plot_metadata_id_pkey"
  primary key ("id");
alter table "operational"."plot_metadata"
  add constraint "plot_metadata_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot_metadata"
  add constraint "plot_metadata_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "plot_metadata_study_id_idx"
  on "operational"."plot_metadata"
  using btree ("study_id");
create index "plot_metadata_entry_id_idx"
  on "operational"."plot_metadata"
  using btree ("entry_id");
create index "plot_metadata_plot_id_idx"
  on "operational"."plot_metadata"
  using btree ("plot_id");
create index "plot_metadata_variable_id_idx"
  on "operational"."plot_metadata"
  using btree ("variable_id");
create index "plot_metadata_is_void_idx"
  on "operational"."plot_metadata"
  using btree ("is_void");

-- ----------------

create table "operational"."plot_data" (
    "id" serial not null,
    "study_id" integer not null,
    "entry_id" integer not null,
    "plot_id" integer not null,
    "variable_id" integer not null,
    "value" varchar not null,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."plot_data"
  add constraint "plot_data_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot_data"
  add constraint "plot_data_entry_id_fkey"
  foreign key ("entry_id") references "operational"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot_data"
  add constraint "plot_data_plot_id_fkey"
  foreign key ("plot_id") references "operational"."plot" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot_data"
  add constraint "plot_data_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot_data"
  add constraint "plot_data_id_pkey"
  primary key ("id");
alter table "operational"."plot_data"
  add constraint "plot_data_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."plot_data"
  add constraint "plot_data_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "plot_data_study_id_idx"
  on "operational"."plot_data"
  using btree ("study_id");
create index "plot_data_entry_id_idx"
  on "operational"."plot_data"
  using btree ("entry_id");
create index "plot_data_plot_id_idx"
  on "operational"."plot_data"
  using btree ("plot_id");
create index "plot_data_variable_id_idx"
  on "operational"."plot_data"
  using btree ("variable_id");
create index "plot_data_is_void_idx"
  on "operational"."plot_data"
  using btree ("is_void");

-- ----------------

create table "operational"."subplot" (
    "id" serial not null,
    "study_id" integer not null,
    "entry_id" integer not null,
    "plot_id" integer not null,
    "number" integer not null default '1',
    "key" integer not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."subplot"
  add constraint "subplot_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot"
  add constraint "subplot_entry_id_fkey"
  foreign key ("entry_id") references "operational"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot"
  add constraint "subplot_plot_id_fkey"
  foreign key ("plot_id") references "operational"."plot" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot"
  add constraint "subplot_id_pkey"
  primary key ("id");
alter table "operational"."subplot"
  add constraint "subplot_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot"
  add constraint "subplot_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "subplot_study_id_idx"
  on "operational"."subplot"
  using btree ("study_id");
create index "subplot_entry_id_idx"
  on "operational"."subplot"
  using btree ("entry_id");
create index "subplot_plot_id_idx"
  on "operational"."subplot"
  using btree ("plot_id");
create index "subplot_key_idx"
  on "operational"."subplot"
  using btree ("key");
create index "subplot_is_void_idx"
  on "operational"."subplot"
  using btree ("is_void");

-- ----------------

create table "operational"."subplot_metadata" (
    "id" serial not null,
    "study_id" integer not null,
    "entry_id" integer not null,
    "plot_id" integer not null,
    "subplot_id" integer not null,
    "variable_id" integer not null,
    "value" varchar not null,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."subplot_metadata"
  add constraint "subplot_metadata_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_metadata"
  add constraint "subplot_metadata_entry_id_fkey"
  foreign key ("entry_id") references "operational"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_metadata"
  add constraint "subplot_metadata_plot_id_fkey"
  foreign key ("plot_id") references "operational"."plot" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_metadata"
  add constraint "subplot_metadata_subplot_id_fkey"
  foreign key ("subplot_id") references "operational"."subplot" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_metadata"
  add constraint "subplot_metadata_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_metadata"
  add constraint "subplot_metadata_id_pkey"
  primary key ("id");
alter table "operational"."subplot_metadata"
  add constraint "subplot_metadata_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_metadata"
  add constraint "subplot_metadata_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "subplot_metadata_study_id_idx"
  on "operational"."subplot_metadata"
  using btree ("study_id");
create index "subplot_metadata_entry_id_idx"
  on "operational"."subplot_metadata"
  using btree ("entry_id");
create index "subplot_metadata_plot_id_idx"
  on "operational"."subplot_metadata"
  using btree ("plot_id");
create index "subplot_metadata_subplot_id_idx"
  on "operational"."subplot_metadata"
  using btree ("variable_id");
create index "subplot_metadata_variable_id_idx"
  on "operational"."subplot_metadata"
  using btree ("variable_id");
create index "subplot_metadata_is_void_idx"
  on "operational"."subplot_metadata"
  using btree ("is_void");

-- ----------------

create table "operational"."subplot_data" (
    "id" serial not null,
    "study_id" integer not null,
    "entry_id" integer not null,
    "plot_id" integer not null,
    "subplot_id" integer not null,
    "variable_id" integer not null,
    "value" varchar not null,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."subplot_data"
  add constraint "subplot_data_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_data"
  add constraint "subplot_data_entry_id_fkey"
  foreign key ("entry_id") references "operational"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_data"
  add constraint "subplot_data_plot_id_fkey"
  foreign key ("plot_id") references "operational"."plot" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_data"
  add constraint "subplot_data_subplot_id_fkey"
  foreign key ("subplot_id") references "operational"."subplot" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_data"
  add constraint "subplot_data_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_data"
  add constraint "subplot_data_id_pkey"
  primary key ("id");
alter table "operational"."subplot_data"
  add constraint "subplot_data_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."subplot_data"
  add constraint "subplot_data_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "subplot_data_study_id_idx"
  on "operational"."subplot_data"
  using btree ("study_id");
create index "subplot_data_entry_id_idx"
  on "operational"."subplot_data"
  using btree ("entry_id");
create index "subplot_data_plot_id_idx"
  on "operational"."subplot_data"
  using btree ("plot_id");
create index "subplot_data_subplot_id_idx"
  on "operational"."subplot_data"
  using btree ("variable_id");
create index "subplot_data_variable_id_idx"
  on "operational"."subplot_data"
  using btree ("variable_id");
create index "subplot_data_is_void_idx"
  on "operational"."subplot_data"
  using btree ("is_void");

-- ----------------

create table "operational"."cross" (
    "id" serial not null,
    "study_id" integer not null,
    "female_entry_id" integer not null,
    "female_product_id" integer not null,
    "female_product_name" varchar(128) not null,
    "male_entry_id" integer not null,
    "male_product_id" integer not null,
    "male_product_name" varchar(128) not null,
    "cross_method_id" integer not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."cross"
  add constraint "cross_female_entry_id_fkey"
  foreign key ("female_entry_id") references "operational"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross"
  add constraint "cross_female_product_id_fkey"
  foreign key ("female_product_id") references "master"."product" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross"
  add constraint "cross_male_entry_id_fkey"
  foreign key ("male_entry_id") references "operational"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross"
  add constraint "cross_male_product_id_fkey"
  foreign key ("male_product_id") references "master"."product" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross"
  add constraint "cross_cross_method_id_fkey"
  foreign key ("cross_method_id") references "master"."cross_method" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross"
  add constraint "cross_id_pkey"
  primary key ("id");
alter table "operational"."cross"
  add constraint "cross_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross"
  add constraint "cross_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "cross_study_id_idx"
  on "operational"."cross"
  using btree ("study_id");
create index "cross_female_entry_id_idx"
  on "operational"."cross"
  using btree ("female_entry_id");
create index "cross_female_product_id_idx"
  on "operational"."cross"
  using btree ("female_product_id");
create index "cross_male_entry_id_idx"
  on "operational"."cross"
  using btree ("male_entry_id");
create index "cross_male_product_id_idx"
  on "operational"."cross"
  using btree ("male_product_id");
create index "cross_cross_method_id_idx"
  on "operational"."cross"
  using btree ("cross_method_id");

-- ----------------

create table "operational"."cross_metadata" (
    "id" serial not null,
    "study_id" integer not null,
    "cross_id" integer not null,
    "variable_id" integer not null,
    "value" varchar not null,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."cross_metadata"
  add constraint "cross_metadata_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross_metadata"
  add constraint "cross_metadata_cross_id_fkey"
  foreign key ("cross_id") references "operational"."cross" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross_metadata"
  add constraint "cross_metadata_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross_metadata"
  add constraint "cross_metadata_id_pkey"
  primary key ("id");
alter table "operational"."cross_metadata"
  add constraint "cross_metadata_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross_metadata"
  add constraint "cross_metadata_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "cross_metadata_study_id_idx"
  on "operational"."cross_metadata"
  using btree ("study_id");
create index "cross_metadata_cross_id_idx"
  on "operational"."cross_metadata"
  using btree ("cross_id");
create index "cross_metadata_variable_id_idx"
  on "operational"."cross_metadata"
  using btree ("variable_id");
create index "cross_metadata_is_void_idx"
  on "operational"."cross_metadata"
  using btree ("is_void");

-- ----------------

create table "operational"."cross_data" (
    "id" serial not null,
    "study_id" integer not null,
    "cross_id" integer not null,
    "variable_id" integer not null,
    "value" varchar not null,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."cross_data"
  add constraint "cross_data_study_id_fkey"
  foreign key ("study_id") references "operational"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross_data"
  add constraint "cross_data_cross_id_fkey"
  foreign key ("cross_id") references "operational"."cross" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross_data"
  add constraint "cross_data_variable_id_fkey"
  foreign key ("variable_id") references "master"."variable" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross_data"
  add constraint "cross_data_id_pkey"
  primary key ("id");
alter table "operational"."cross_data"
  add constraint "cross_data_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."cross_data"
  add constraint "cross_data_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "cross_data_study_id_idx"
  on "operational"."cross_data"
  using btree ("study_id");
create index "cross_data_cross_id_idx"
  on "operational"."cross_data"
  using btree ("cross_id");
create index "cross_data_variable_id_idx"
  on "operational"."cross_data"
  using btree ("variable_id");
create index "cross_data_is_void_idx"
  on "operational"."cross_data"
  using btree ("is_void");

-- --------------------------------

create schema "warehouse";

create table "warehouse"."study" (
    "id" serial not null,
    "program_id" integer not null,
    "place_id" integer not null,
    "phase_id" integer not null,
    "year" integer not null,
    "season_id" integer not null,
    "sequence_number" integer not null,
    "key" integer not null,
    "name" varchar(128) not null,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "warehouse"."study"
  add constraint "study_program_id_fkey"
  foreign key ("program_id") references "master"."program" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."study"
  add constraint "study_place_id_fkey"
  foreign key ("place_id") references "master"."place" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."study"
  add constraint "study_phase_id_fkey"
  foreign key ("phase_id") references "master"."phase" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."study"
  add constraint "study_season_id_fkey"
  foreign key ("season_id") references "master"."season" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."study"
  add constraint "study_id_pkey"
  primary key ("id");
alter table "warehouse"."study"
  add constraint "study_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."study"
  add constraint "study_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "study_program_id_idx"
  on "warehouse"."study"
  using btree ("program_id");
create index "study_place_id_idx"
  on "warehouse"."study"
  using btree ("place_id");
create index "study_phase_id_idx"
  on "warehouse"."study"
  using btree ("phase_id");
create index "study_year_idx"
  on "warehouse"."study"
  using btree ("year");
create index "study_season_id_idx"
  on "warehouse"."study"
  using btree ("season_id");
create index "study_year_season_id_idx"
  on "warehouse"."study"
  using btree ("year", "season_id");
create index "study_key_idx"
  on "warehouse"."study"
  using btree ("key");
create index "study_name_idx"
  on "warehouse"."study"
  using btree ("name");
create index "study_is_void_idx"
  on "warehouse"."study"
  using btree ("is_void");

-- ----------------

create table "warehouse"."entry" (
    "id" serial not null,
    "study_id" integer not null,
    "number" integer not null default '1',
    "key" integer not null,
    "code" varchar,
    "product_id" integer not null,
    "product_gid" integer not null,
    "product_name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "warehouse"."entry"
  add constraint "entry_study_id_fkey"
  foreign key ("study_id") references "warehouse"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."entry"
  add constraint "entry_product_id_fkey"
  foreign key ("product_id") references "master"."product" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."entry"
  add constraint "entry_id_pkey"
  primary key ("id");
alter table "warehouse"."entry"
  add constraint "entry_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."entry"
  add constraint "entry_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "entry_study_id_idx"
  on "warehouse"."entry"
  using btree ("study_id");
create index "entry_key_idx"
  on "warehouse"."entry"
  using btree ("key");
create index "entry_product_id_idx"
  on "warehouse"."entry"
  using btree ("product_id");
create index "entry_is_void_idx"
  on "warehouse"."entry"
  using btree ("is_void");

-- ----------------

create table "warehouse"."plot" (
    "id" serial not null,
    "study_id" integer not null,
    "entry_id" integer not null,
    "replication_number" integer,
    "key" integer not null,
    "code" varchar,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "warehouse"."plot"
  add constraint "plot_study_id_fkey"
  foreign key ("study_id") references "warehouse"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."plot"
  add constraint "plot_entry_id_fkey"
  foreign key ("entry_id") references "warehouse"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."plot"
  add constraint "plot_id_pkey"
  primary key ("id");
alter table "warehouse"."plot"
  add constraint "plot_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."plot"
  add constraint "plot_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "plot_study_id_idx"
  on "warehouse"."plot"
  using btree ("study_id");
create index "plot_entry_id_idx"
  on "warehouse"."plot"
  using btree ("entry_id");
create index "plot_key_idx"
  on "warehouse"."plot"
  using btree ("key");
create index "plot_is_void_idx"
  on "warehouse"."plot"
  using btree ("is_void");

-- ----------------

create table "warehouse"."subplot" (
    "id" serial not null,
    "study_id" integer not null,
    "entry_id" integer not null,
    "plot_id" integer not null,
    "number" integer not null default '1',
    "key" integer not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "warehouse"."subplot"
  add constraint "subplot_study_id_fkey"
  foreign key ("study_id") references "warehouse"."study" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."subplot"
  add constraint "subplot_entry_id_fkey"
  foreign key ("entry_id") references "warehouse"."entry" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."subplot"
  add constraint "subplot_plot_id_fkey"
  foreign key ("plot_id") references "warehouse"."plot" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."subplot"
  add constraint "subplot_id_pkey"
  primary key ("id");
alter table "warehouse"."subplot"
  add constraint "subplot_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "warehouse"."subplot"
  add constraint "subplot_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "subplot_study_id_idx"
  on "warehouse"."subplot"
  using btree ("study_id");
create index "subplot_entry_id_idx"
  on "warehouse"."subplot"
  using btree ("entry_id");
create index "subplot_plot_id_idx"
  on "warehouse"."subplot"
  using btree ("plot_id");
create index "subplot_key_idx"
  on "warehouse"."subplot"
  using btree ("key");
create index "subplot_is_void_idx"
  on "warehouse"."subplot"
  using btree ("is_void");



-- --------------------------------

insert into "master"."user" (
    "email",
    "username",
    "last_name",
    "first_name",
    "display_name",
    "user_type"
) values (
    'bims.irri@gmail.com',
    'bims.irri',
    'IRRI',
    'BIMS',
    'IRRI, BIMS',
    '1'
);

-- ---------------------------------------------------

-- DROP TRIGGER add_variable_column ON master."variable";
-- DROP FUNCTION public.add_variable_column();

create or replace function "master"."add_variable_column"() returns trigger as $add_var_col$
declare
    column_name varchar;
    data_type varchar;
    not_null varchar;

    add_column varchar;
begin
    -- if (upper(new."type") = 'METADATA' or upper(new."type") = 'OBSERVATION') then
    if (upper(new."type") = 'OBSERVATION') then
        -- column name
        if (new."abbrev" is null or trim(new.abbrev) = '') then
            column_name := '"' || lower(new."name") || '"';
        else
            column_name := '"' || lower(new."abbrev") || '"';
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

        -- add column to warehouse.subplot
        execute
            'alter table "warehouse"."subplot" ' || add_column;
    end if;

    return new;
end;
$add_var_col$ language plpgsql;

create trigger "add_variable_column"
    after insert on "master"."variable"
    for each row execute procedure "master"."add_variable_column"();

/*insert into "master"."property" (
    "abbrev",
    "name",
    "description"
) values (
    'ht',
    'plant height',
    'Plant height measured from the soil surface to the tip of the tallest panicle (awn excluded). At growth stage: 7-9. [CO:rs]'
);

insert into "master"."method" (
    "abbrev",
    "name",
    "description"
) values (
    'ht_measured',
    'plant height measured',
    'Use actual measurement (cm) from soil surface to tip of the tallest panicle (awns excluded) or flag leaf. For height measurements at other growth stages, specify the stage. Record in whole numbers (do not use decimals). []'
);

insert into "master"."scale" (
    "abbrev",
    "name",
    "description",
    "unit",
    "type"
) values (
    'ht_measured_continuous',
    'plant height measured continuous',
    '1= Semidwarf (lowland: less than 110 cm); upland: less than 90 cm)\n5= intermediate (lowland: 110-130 cm; upland: 90-125 cm)\n9= Tall (lowland: more than 130 cm; upland: more than 125 cm)',
    'cm',
    'continuous'
);*/

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
        || row_number() over (partition by lower(trim("name"))) abbrev,
    var.name || ' ' || row_number() over (partition by lower(trim("name"))) abbrev,
    trim(var.method) description
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
        || row_number() over (partition by lower(trim("name"))) abbrev,
    var.name || ' ' || row_number() over (partition by lower(trim("name"))) abbrev,
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
                var.abbrev || '_' || (trunc((random() * 10)::numeric, 2) + 1)
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
order by
    mv.id
;

