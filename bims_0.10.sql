select pg_terminate_backend(pid) from pg_stat_activity where datname='bims_0.10' and pid <> pg_backend_pid();

-- --------------------------------

drop schema if exists "master" cascade;

drop schema if exists "dictionary" cascade;

drop schema if exists "operational" cascade;

drop schema if exists "warehouse" cascade;

-- --------------------------------

-- create database "bims_0.10"
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
    "program_id" integer not null,
    "designation" varchar not null,
    "name_type" varchar not null,
    "type" varchar not null,
    "year" integer not null,
    "season_id" integer,
    "mta_status" varchar not null,
    "parentage" varchar,
    "cross_id" integer,
    "generation" varchar not null,
    "iris_preferred_id" varchar,
    "breeding_line_name" varchar,
    "derivative_name" varchar,
    "fixed_line_name" varchar,
    "selection_method" varchar,
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
  add constraint "product_program_id_fkey"
  foreign key ("program_id") references "master"."program" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."product"
  add constraint "product_cross_id_fkey"
  foreign key ("cross_id") references "operational"."cross" ("id")
  match simple on update cascade on delete cascade;
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

create index "product_program_id_idx"
  on "master"."product"
  using btree ("program_id");
create index "product_designation_idx"
  on "master"."product"
  using btree ("designation");
create index "product_name_type_idx"
  on "master"."product"
  using btree ("name_type");
create index "product_type_idx"
  on "master"."product"
  using btree ("type");
create index "product_year_idx"
  on "master"."product"
  using btree ("year");
create index "product_season_id_idx"
  on "master"."product"
  using btree ("season_id");
create index "product_cross_id_idx"
  on "master"."product"
  using btree ("cross_id");
create index "product_generation_idx"
  on "master"."product"
  using btree ("generation");
create unique index "product_abbrev_idx"
  on "master"."product"
  using btree ("abbrev");
create index "product_is_void_idx"
  on "master"."product"
  using btree ("is_void");

-- ----------------

create table "master"."product_name" (
    "id" serial not null,
    "product_id" integer not null,
    "name_type" varchar not null,
    "value" varchar not null,
    "language_code" varchar not null default 'eng',
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

alter table "master"."product_name"
  add constraint "product_name_product_id_fkey"
  foreign key ("product_id") references "master"."product" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."product_name"
  add constraint "product_name_id_pkey"
  primary key ("id");
alter table "master"."product_name"
  add constraint "product_name_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "master"."product_name"
  add constraint "product_name_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "product_name_product_id_idx"
  on "master"."product_name"
  using btree ("product_id");
create index "product_name_name_type_idx"
  on "master"."product_name"
  using btree ("name_type");
create index "product_name_is_void_idx"
  on "master"."product_name"
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
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
    "name" varchar(256) not null,
    "title" varchar,
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
    "product_name" varchar(256) not null,
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
    "female_product_name" varchar(256) not null,
    "male_entry_id" integer not null,
    "male_product_id" integer not null,
    "male_product_name" varchar(256) not null,
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

-- ----------------

create table "operational"."seed_storage" (
    "id" serial not null,
    "product_id" integer not null,
    "seed_lot_id" integer not null,
    "key_type" varchar not null,
    "seed_manager" varchar not null,
    "gid" integer not null,
    "volume" float not null,
    "unit" varchar not null,
    "harvest_date" date,
    "label" varchar not null,
    "original_storage_id" integer,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."seed_storage"
  add constraint "seed_storage_product_id_fkey"
  foreign key ("product_id") references "master"."product" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."seed_storage"
  add constraint "seed_storage_id_pkey"
  primary key ("id");
alter table "operational"."seed_storage"
  add constraint "seed_storage_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."seed_storage"
  add constraint "seed_storage_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "seed_storage_product_id_idx"
  on "operational"."seed_storage"
  using btree ("product_id");
create unique index "seed_storage_seed_lot_id_idx"
  on "operational"."seed_storage"
  using btree ("seed_lot_id");
create unique index "seed_storage_gid_idx"
  on "operational"."seed_storage"
  using btree ("gid");
create index "seed_storage_original_storage_id_idx"
  on "operational"."seed_storage"
  using btree ("original_storage_id");
create index "seed_storage_is_void_idx"
  on "operational"."seed_storage"
  using btree ("is_void");

-- ----------------

create table "operational"."seed_storage_log" (
    "id" serial not null,
    "seed_storage_id" integer not null,
    "encoder_id" integer not null,
    "encode_timestamp" timestamp not null,
    "transaction_type" varchar not null,
    "volume" float not null,
    "unit" varchar not null,
    "event_timestamp" timestamp not null,
    "sender" varchar,
    "receiver" varchar,
    "creation_timestamp" timestamp not null default now(),
    "creator_id" integer not null default '1',
    "modification_timestamp" timestamp,
    "modifier_id" integer,
    "notes" text,
    "is_void" boolean not null default false
) with (
    oids = false
);

alter table "operational"."seed_storage_log"
  add constraint "seed_storage_log_seed_storage_id_fkey"
  foreign key ("seed_storage_id") references "operational"."seed_storage" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."seed_storage_log"
  add constraint "seed_storage_log_encoder_id_fkey"
  foreign key ("encoder_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."seed_storage_log"
  add constraint "seed_storage_log_id_pkey"
  primary key ("id");
alter table "operational"."seed_storage_log"
  add constraint "seed_storage_log_creator_id_fkey"
  foreign key ("creator_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;
alter table "operational"."seed_storage_log"
  add constraint "seed_storage_log_modifier_id_fkey"
  foreign key ("modifier_id") references "master"."user" ("id")
  match simple on update cascade on delete cascade;

create index "seed_storage_log_seed_storage_id_idx"
  on "operational"."seed_storage_log"
  using btree ("seed_storage_id");
create index "seed_storage_transaction_type_idx"
  on "operational"."seed_storage_log"
  using btree ("transaction_type");
create index "seed_storage_log_is_void_idx"
  on "operational"."seed_storage_log"
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
    "name" varchar(256) not null,
    "title" varchar,
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
    "product_name" varchar(256) not null,
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

comment on database "bims_0.10"
  is 'BIMS: Breeding Information Management System';

comment on schema "master"
  is 'Stores master data, which are absolutely correct data that does not change frequently';

comment on table "master"."user"
  is 'Users';

comment on column "master"."user"."id"
  is 'Locally unique primary key';

comment on column "master"."user"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."user"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."user"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."user"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."user"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."user"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."user_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "user_creator_id_fkey" on "master"."user"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "user_modifier_id_fkey" on "master"."user"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."user_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."property"
  is 'Property describes the context of the sampling unit and experimental material, or the trait being measured.';

comment on column "master"."property"."id"
  is 'Locally unique primary key';

comment on column "master"."property"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."property"."name"
  is 'Name identifier';

comment on column "master"."property"."description"
  is 'Description';

comment on column "master"."property"."remarks"
  is 'Additional details';

comment on column "master"."property"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."property"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."property"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."property"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."property"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."property"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."property_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "property_creator_id_fkey" on "master"."property"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "property_modifier_id_fkey" on "master"."property"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."property_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."property_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."method"
  is 'Method describes how the property is applied or the protocol by which a variable is measured.';

comment on column "master"."method"."id"
  is 'Locally unique primary key';

comment on column "master"."method"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."method"."description"
  is 'Description';

comment on column "master"."method"."remarks"
  is 'Additional details';

comment on column "master"."method"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."method"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."method"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."method"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."method"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."method"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."method_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "method_creator_id_fkey" on "master"."method"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "method_modifier_id_fkey" on "master"."method"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."method_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."method_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."scale"
  is 'Scale describes the units in which the variables are recorded.';

comment on column "master"."scale"."id"
  is 'Locally unique primary key';

comment on column "master"."scale"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."scale"."name"
  is 'Name identifier';

comment on column "master"."scale"."type"
  is 'categorical; continuous; discrete';

comment on column "master"."scale"."level"
  is 'nominal; ordinal; interval; ratio';

comment on column "master"."scale"."description"
  is 'Description';

comment on column "master"."scale"."remarks"
  is 'Additional details';

comment on column "master"."scale"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."scale"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."scale"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."scale"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."scale"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."scale"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."scale_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "scale_creator_id_fkey" on "master"."scale"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "scale_modifier_id_fkey" on "master"."scale"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."scale_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."scale_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."scale_value"
  is 'Discrete values a scale can have.';

comment on column "master"."scale_value"."id"
  is 'Locally unique primary key';

comment on column "master"."scale_value"."description"
  is 'Description';

comment on column "master"."scale_value"."remarks"
  is 'Additional details';

comment on column "master"."scale_value"."order_number"
  is 'Ordering number';

comment on column "master"."scale_value"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."scale_value"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."scale_value"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."scale_value"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."scale_value"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."scale_value"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."scale_value_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "scale_value_creator_id_fkey" on "master"."scale_value"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "scale_value_modifier_id_fkey" on "master"."scale_value"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."scale_value_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."variable"
  is 'Variables';

comment on column "master"."variable"."id"
  is 'Locally unique primary key';

comment on column "master"."variable"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."variable"."name"
  is 'Name identifier';

comment on column "master"."variable"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."variable"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."variable"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."variable"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."variable"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."variable"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."variable_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "variable_creator_id_fkey" on "master"."variable"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "variable_modifier_id_fkey" on "master"."variable"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."variable_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."variable_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."variable_set"
  is 'Groups of variables';

comment on column "master"."variable_set"."id"
  is 'Locally unique primary key';

comment on column "master"."variable_set"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."variable_set"."name"
  is 'Name identifier';

comment on column "master"."variable_set"."description"
  is 'Description';

comment on column "master"."variable_set"."remarks"
  is 'Additional details';

comment on column "master"."variable_set"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."variable_set"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."variable_set"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."variable_set"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."variable_set"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."variable_set"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."variable_set_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "variable_set_creator_id_fkey" on "master"."variable_set"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "variable_set_modifier_id_fkey" on "master"."variable_set"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."variable_set_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."variable_set_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."variable_set_member"
  is 'variables';

comment on column "master"."variable_set_member"."id"
  is 'Locally unique primary key';

comment on column "master"."variable_set_member"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."variable_set_member"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."variable_set_member"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."variable_set_member"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."variable_set_member"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."variable_set_member"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."variable_set_member_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "variable_set_member_creator_id_fkey" on "master"."variable_set_member"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "variable_set_member_modifier_id_fkey" on "master"."variable_set_member"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."variable_set_member_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."pipeline"
  is 'A product development schema designed to develop breeding products to a certain demand (market segment).
At IRRI, VDPs are structured based on major regions and production ecologies
  - Irrigated South East Asia (IR SEA)
  - Rainfed lowland South East Asia (RF SEA)
  - Irrigated South Asia (IR SA)
  - Rainfed lowland South Asia (RF SA)
  - Hybrid
  - Eastern Southern Africa (ESA) - has Rainfed and Irrigated TVP''s,
  - Japonica - has Temperate and Tropical TVP''s';

comment on column "master"."pipeline"."id"
  is 'Locally unique primary key';

comment on column "master"."pipeline"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."pipeline"."name"
  is 'Name identifier';

comment on column "master"."pipeline"."description"
  is 'Description';

comment on column "master"."pipeline"."remarks"
  is 'Additional details';

comment on column "master"."pipeline"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."pipeline"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."pipeline"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."pipeline"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."pipeline"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."pipeline"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."pipeline_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "pipeline_creator_id_fkey" on "master"."pipeline"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "pipeline_modifier_id_fkey" on "master"."pipeline"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."pipeline_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."pipeline_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."crosscutting"
  is 'Breeding process that provides expert service for the whole breeding operation of an organization.
CCRD consists of a team of experts, the CCRD facility, and operational and capital resources.';

comment on column "master"."crosscutting"."id"
  is 'Locally unique primary key';

comment on column "master"."crosscutting"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."crosscutting"."name"
  is 'Name identifier';

comment on column "master"."crosscutting"."description"
  is 'Description';

comment on column "master"."crosscutting"."remarks"
  is 'Additional details';

comment on column "master"."crosscutting"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."crosscutting"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."crosscutting"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."crosscutting"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."crosscutting"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."crosscutting"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."crosscutting_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "crosscutting_creator_id_fkey" on "master"."crosscutting"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "crosscutting_modifier_id_fkey" on "master"."crosscutting"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."crosscutting_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."crosscutting_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."program"
  is 'Consist of variety development pipelines (VDPs), trait development teams and cross-cutting activities (CCRDs).
Products of VDPs are varieties, breeding lines, parental lines and other genetic materials in different stages of a breeding scheme, and IP related to the genetic materials.
Products of trait development are discovered trait donors, QTL''s and genes, and marker application for selection of those, and related IP.
Trait development products work through different type IP-solutions than variety development.';

comment on column "master"."program"."id"
  is 'Locally unique primary key';

comment on column "master"."program"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."program"."name"
  is 'Name identifier';

comment on column "master"."program"."description"
  is 'Description';

comment on column "master"."program"."remarks"
  is 'Additional details';

comment on column "master"."program"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."program"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."program"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."program"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."program"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."program"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."program_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "program_creator_id_fkey" on "master"."program"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "program_modifier_id_fkey" on "master"."program"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."program_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."program_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."place"
  is 'Represents the physical places and their segmentations such as geographies, locations, areas, zones, etc.
  - Breeding hub
  - Breeding location
  - Facility
  - Field
  - Farm
  - Glasshouse
  - Warehouse
  - Storage';

comment on column "master"."place"."id"
  is 'Locally unique primary key';

comment on column "master"."place"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."place"."name"
  is 'Name identifier';

comment on column "master"."place"."description"
  is 'Description';

comment on column "master"."place"."remarks"
  is 'Additional details';

comment on column "master"."place"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."place"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."place"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."place"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."place"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."place"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."place_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "place_creator_id_fkey" on "master"."place"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "place_modifier_id_fkey" on "master"."place"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."place_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."place_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."phase"
  is 'Breeding development phases';

comment on column "master"."phase"."id"
  is 'Locally unique primary key';

comment on column "master"."phase"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."phase"."name"
  is 'Name identifier';

comment on column "master"."phase"."description"
  is 'Description';

comment on column "master"."phase"."remarks"
  is 'Additional details';

comment on column "master"."phase"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."phase"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."phase"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."phase"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."phase"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."phase"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."phase_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "phase_creator_id_fkey" on "master"."phase"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "phase_modifier_id_fkey" on "master"."phase"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."phase_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."phase_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."product"
  is 'Product catalog is a publicly accessible list of the products used and produced in product development programs.
Every record has a unique key and unique product name. It contains the identity of a material.';

comment on column "master"."product"."id"
  is 'Locally unique primary key';

comment on column "master"."product"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."product"."name"
  is 'Name identifier';

comment on column "master"."product"."program_id"
  is 'Foreign key to the product development program table';

comment on column "master"."product"."name_type"
  is 'Name types: breeding_line, fixed_line, derivative, common, cultivar';

comment on column "master"."product"."type"
  is 'Product types: progeny, fixed_line';

comment on column "master"."product"."mta_status"
  is 'Refers to the set of defined terms to guide the legal use of material i.e. SMTA, CMTA, OMTA, Confidential';

comment on column "master"."product"."generation"
  is 'Generations: UNKNOWN, F1, BC1F1, BC2F1, BC3F1, F2, F3, F4, FIXED';

comment on column "master"."product"."description"
  is 'Description';

comment on column "master"."product"."remarks"
  is 'Additional details';

comment on column "master"."product"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."product"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."product"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."product"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."product"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."product"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."product_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "product_creator_id_fkey" on "master"."product"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "product_modifier_id_fkey" on "master"."product"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."product_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."product_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."product_name"
  is 'Names of a product';

comment on column "master"."product_name"."id"
  is 'Locally unique primary key';

comment on column "master"."product_name"."name_type"
  is 'derivative, fixed_line, cultivar, common';

comment on column "master"."product_name"."language_code"
  is 'Reference: http://www.loc.gov/standards/iso639-2/php/code_list.php';

comment on column "master"."product_name"."description"
  is 'Description';

comment on column "master"."product_name"."remarks"
  is 'Additional details';

comment on column "master"."product_name"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."product_name"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."product_name"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."product_name"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."product_name"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."product_name"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."product_name_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "product_name_creator_id_fkey" on "master"."product_name"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "product_name_modifier_id_fkey" on "master"."product_name"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."product_name_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."product_metadata"
  is 'Additional information about products';

comment on column "master"."product_metadata"."id"
  is 'Locally unique primary key';

comment on column "master"."product_metadata"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."product_metadata"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."product_metadata"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."product_metadata"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."product_metadata"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."product_metadata"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."product_metadata_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "product_metadata_creator_id_fkey" on "master"."product_metadata"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "product_metadata_modifier_id_fkey" on "master"."product_metadata"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."product_metadata_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."season"
  is 'List of seasons';

comment on column "master"."season"."id"
  is 'Locally unique primary key';

comment on column "master"."season"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."season"."name"
  is 'Name identifier';

comment on column "master"."season"."description"
  is 'Description';

comment on column "master"."season"."remarks"
  is 'Additional details';

comment on column "master"."season"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."season"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."season"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."season"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."season"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."season"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."season_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "season_creator_id_fkey" on "master"."season"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "season_modifier_id_fkey" on "master"."season"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."season_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."season_is_void_idx"
  is 'Index for the is_void column';

comment on table "master"."place_season"
  is 'List of seasons in a place';

comment on column "master"."place_season"."id"
  is 'Locally unique primary key';

comment on column "master"."place_season"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."place_season"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."place_season"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."place_season"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."place_season"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."place_season"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."place_season_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "place_season_creator_id_fkey" on "master"."place_season"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "place_season_modifier_id_fkey" on "master"."place_season"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on table "master"."cross_method"
  is 'Methods used in crossing studies';

comment on column "master"."cross_method"."id"
  is 'Locally unique primary key';

comment on column "master"."cross_method"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."cross_method"."name"
  is 'Name identifier';

comment on column "master"."cross_method"."description"
  is 'Description';

comment on column "master"."cross_method"."remarks"
  is 'Additional details';

comment on column "master"."cross_method"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "master"."cross_method"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "master"."cross_method"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "master"."cross_method"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "master"."cross_method"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "master"."cross_method"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "master"."cross_method_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "cross_method_creator_id_fkey" on "master"."cross_method"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "cross_method_modifier_id_fkey" on "master"."cross_method"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "master"."cross_method_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "master"."cross_method_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."database"
  is 'Data sources';

comment on column "dictionary"."database"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."database"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."database"."name"
  is 'Name identifier';

comment on column "dictionary"."database"."comment"
  is 'Additional details';

comment on column "dictionary"."database"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."database"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."database"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."database"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."database"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."database"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "dictionary"."database_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "database_creator_id_fkey" on "dictionary"."database"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "database_modifier_id_fkey" on "dictionary"."database"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."database_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."database_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."schema"
  is 'Schemas in a database';

comment on column "dictionary"."schema"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."schema"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."schema"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."schema"."name"
  is 'Name identifier';

comment on column "dictionary"."schema"."comment"
  is 'Additional details';

comment on column "dictionary"."schema"."description"
  is 'Description';

comment on column "dictionary"."schema"."remarks"
  is 'Additional details';

comment on column "dictionary"."schema"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."schema"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."schema"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."schema"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."schema"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."schema"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "schema_database_id_fkey" on "dictionary"."schema"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on index "dictionary"."schema_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "schema_creator_id_fkey" on "dictionary"."schema"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "schema_modifier_id_fkey" on "dictionary"."schema"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."schema_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."schema_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."table"
  is 'Tables in a schema';

comment on column "dictionary"."table"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."table"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."table"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."table"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."table"."name"
  is 'Name identifier';

comment on column "dictionary"."table"."comment"
  is 'Additional details';

comment on column "dictionary"."table"."description"
  is 'Description';

comment on column "dictionary"."table"."remarks"
  is 'Additional details';

comment on column "dictionary"."table"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."table"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."table"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."table"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."table"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."table"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "table_database_id_fkey" on "dictionary"."table"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "table-schema_id_fkey" on "dictionary"."table"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on index "dictionary"."table_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "table_creator_id_fkey" on "dictionary"."table"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "table_modifier_id_fkey" on "dictionary"."table"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."table_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."table_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."column"
  is 'Columns of a table';

comment on column "dictionary"."column"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."column"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."column"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."column"."table_id"
  is 'ID of the table to use as reference key';

comment on column "dictionary"."column"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."column"."name"
  is 'Name identifier';

comment on column "dictionary"."column"."data_type"
  is 'Type of data the column can store';

comment on column "dictionary"."column"."length"
  is 'Maximum character size for text data types or precision for numeric data types';

comment on column "dictionary"."column"."not_null"
  is 'Whether the column will not allow null values';

comment on column "dictionary"."column"."default_value"
  is 'Default value to fill in the column if value is not explicitly provided';

comment on column "dictionary"."column"."comment"
  is 'Additional details';

comment on column "dictionary"."column"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."column"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."column"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."column"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."column"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."column"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "column_database_id_fkey" on "dictionary"."column"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "column-schema_id_fkey" on "dictionary"."column"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on constraint "column_table_id_fkey" on "dictionary"."column"
  is 'Foreign key constraint for the table_id column, which refers to the id column of the dictionary.table table';

comment on index "dictionary"."column_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "column_creator_id_fkey" on "dictionary"."column"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "column_modifier_id_fkey" on "dictionary"."column"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."column_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."column_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."constraint"
  is 'Constraints of table columns';

comment on column "dictionary"."constraint"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."constraint"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."constraint"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."constraint"."table_id"
  is 'ID of the table to use as reference key';

comment on column "dictionary"."constraint"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."constraint"."name"
  is 'Name identifier';

comment on column "dictionary"."constraint"."type"
  is 'Primary key (primary_key), foreign key (foreign_key), or check (check) constraint';

comment on column "dictionary"."constraint"."column_id"
  is 'Subject column of the constraint';

comment on column "dictionary"."constraint"."command"
  is 'SQL body command of the constraint';

comment on column "dictionary"."constraint"."foreign_table_id"
  is 'Reference table for foreign key constraint only';

comment on column "dictionary"."constraint"."foreign_column_id"
  is 'Column of the reference table for foreign key constraint only';

comment on column "dictionary"."constraint"."comment"
  is 'Additional details';

comment on column "dictionary"."constraint"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."constraint"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."constraint"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."constraint"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."constraint"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."constraint"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "constraint_database_id_fkey" on "dictionary"."constraint"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "constraint-schema_id_fkey" on "dictionary"."constraint"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on constraint "constraint_table_id_fkey" on "dictionary"."constraint"
  is 'Foreign key constraint for the table_id column, which refers to the id column of the dictionary.table table';

comment on constraint "constraint-column_id_fkey" on "dictionary"."constraint"
  is 'Foreign key constraint for the column_id column, which refers to the id column of the dictionary.column table';

comment on index "dictionary"."constraint_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "constraint_creator_id_fkey" on "dictionary"."constraint"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "constraint_modifier_id_fkey" on "dictionary"."constraint"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."constraint_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."constraint_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."index"
  is 'Indexes of table columns';

comment on column "dictionary"."index"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."index"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."index"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."index"."table_id"
  is 'ID of the table to use as reference key';

comment on column "dictionary"."index"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."index"."name"
  is 'Name identifier';

comment on column "dictionary"."index"."column_id"
  is 'Subject column of the index';

comment on column "dictionary"."index"."using"
  is 'Algorithm to use in indexing';

comment on column "dictionary"."index"."unique"
  is 'Whether the index is unique or not';

comment on column "dictionary"."index"."concurrent"
  is 'Whether the index is concurrent or not';

comment on column "dictionary"."index"."comment"
  is 'Additional details';

comment on column "dictionary"."index"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."index"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."index"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."index"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."index"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."index"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "index_database_id_fkey" on "dictionary"."index"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "index-schema_id_fkey" on "dictionary"."index"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on constraint "index_table_id_fkey" on "dictionary"."index"
  is 'Foreign key constraint for the table_id column, which refers to the id column of the dictionary.table table';

comment on constraint "index-column_id_fkey" on "dictionary"."index"
  is 'Foreign key constraint for the column_id column, which refers to the id column of the dictionary.column table';

comment on index "dictionary"."index_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "index_creator_id_fkey" on "dictionary"."index"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "index_modifier_id_fkey" on "dictionary"."index"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."index_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."index_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."rule"
  is 'Rules';

comment on column "dictionary"."rule"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."rule"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."rule"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."rule"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."rule"."name"
  is 'Name identifier';

comment on column "dictionary"."rule"."event"
  is 'At what event/s the rule will be applied';

comment on column "dictionary"."rule"."execution"
  is 'Execution type of the rule';

comment on column "dictionary"."rule"."condition"
  is 'Conditional expression of the rule';

comment on column "dictionary"."rule"."command"
  is 'SQL body command of the rule';

comment on column "dictionary"."rule"."comment"
  is 'Additional details';

comment on column "dictionary"."rule"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."rule"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."rule"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."rule"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."rule"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."rule"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "rule_database_id_fkey" on "dictionary"."rule"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "rule-schema_id_fkey" on "dictionary"."rule"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on index "dictionary"."rule_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "rule_creator_id_fkey" on "dictionary"."rule"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "rule_modifier_id_fkey" on "dictionary"."rule"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."rule_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."rule_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."trigger"
  is 'Triggers';

comment on column "dictionary"."trigger"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."trigger"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."trigger"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."trigger"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."trigger"."name"
  is 'Name identifier';

comment on column "dictionary"."trigger"."enabled"
  is 'Whether the trigger is enabled to execute or not';

comment on column "dictionary"."trigger"."execution"
  is 'Execution type of trigger';

comment on column "dictionary"."trigger"."for_each"
  is 'Apply trigger for each row or statement';

comment on column "dictionary"."trigger"."event"
  is 'At what event/s the trigger will be executed';

comment on column "dictionary"."trigger"."comment"
  is 'Additional details';

comment on column "dictionary"."trigger"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."trigger"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."trigger"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."trigger"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."trigger"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."trigger"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "trigger_database_id_fkey" on "dictionary"."trigger"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "trigger-schema_id_fkey" on "dictionary"."trigger"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on index "dictionary"."trigger_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "trigger_creator_id_fkey" on "dictionary"."trigger"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "trigger_modifier_id_fkey" on "dictionary"."trigger"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."trigger_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."trigger_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."view"
  is 'Views';

comment on column "dictionary"."view"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."view"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."view"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."view"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."view"."name"
  is 'Name identifier';

comment on column "dictionary"."view"."command"
  is 'SQL body command of the view';

comment on column "dictionary"."view"."comment"
  is 'Additional details';

comment on column "dictionary"."view"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."view"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."view"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."view"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."view"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."view"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "view_database_id_fkey" on "dictionary"."view"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "view-schema_id_fkey" on "dictionary"."view"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on index "dictionary"."view_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "view_creator_id_fkey" on "dictionary"."view"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "view_modifier_id_fkey" on "dictionary"."view"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."view_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."view_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."sequence"
  is 'Sequences';

comment on column "dictionary"."sequence"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."sequence"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."sequence"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."sequence"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."sequence"."name"
  is 'Name identifier';

comment on column "dictionary"."sequence"."comment"
  is 'Additional details';

comment on column "dictionary"."sequence"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."sequence"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."sequence"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."sequence"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."sequence"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."sequence"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "sequence_database_id_fkey" on "dictionary"."sequence"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "sequence-schema_id_fkey" on "dictionary"."sequence"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on index "dictionary"."sequence_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "sequence_creator_id_fkey" on "dictionary"."sequence"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "sequence_modifier_id_fkey" on "dictionary"."sequence"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."sequence_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."sequence_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."function"
  is 'Functions';

comment on column "dictionary"."function"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."function"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."function"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."function"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."function"."name"
  is 'Name identifier';

comment on column "dictionary"."function"."comment"
  is 'Additional details';

comment on column "dictionary"."function"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."function"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."function"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."function"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."function"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."function"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "function_database_id_fkey" on "dictionary"."function"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "function-schema_id_fkey" on "dictionary"."function"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on index "dictionary"."function_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "function_creator_id_fkey" on "dictionary"."function"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "function_modifier_id_fkey" on "dictionary"."function"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."function_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."function_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."domain"
  is 'Domains';

comment on column "dictionary"."domain"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."domain"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."domain"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."domain"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."domain"."name"
  is 'Name identifier';

comment on column "dictionary"."domain"."comment"
  is 'Additional details';

comment on column "dictionary"."domain"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."domain"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."domain"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."domain"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."domain"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."domain"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "domain_database_id_fkey" on "dictionary"."domain"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "domain-schema_id_fkey" on "dictionary"."domain"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on index "dictionary"."domain_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "domain_creator_id_fkey" on "dictionary"."domain"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "domain_modifier_id_fkey" on "dictionary"."domain"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."domain_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."domain_is_void_idx"
  is 'Index for the is_void column';

comment on table "dictionary"."aggregate"
  is 'Aggregates';

comment on column "dictionary"."aggregate"."id"
  is 'Locally unique primary key';

comment on column "dictionary"."aggregate"."database_id"
  is 'ID of the database to use as reference key';

comment on column "dictionary"."aggregate"."schema_id"
  is 'ID of the schema to use as reference key';

comment on column "dictionary"."aggregate"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "dictionary"."aggregate"."name"
  is 'Name identifier';

comment on column "dictionary"."aggregate"."comment"
  is 'Additional details';

comment on column "dictionary"."aggregate"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "dictionary"."aggregate"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "dictionary"."aggregate"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "dictionary"."aggregate"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "dictionary"."aggregate"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "dictionary"."aggregate"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "aggregate_database_id_fkey" on "dictionary"."aggregate"
  is 'Foreign key constraint for the database_id column, which refers to the id column of the dictionary.database table';

comment on constraint "aggregate-schema_id_fkey" on "dictionary"."aggregate"
  is 'Foreign key constraint for the schema_id column, which refers to the id column of the dictionary.schema table';

comment on constraint "aggregate_state_function_id_fkey" on "dictionary"."aggregate"
  is 'Foreign key constraint for the state_function_id column, which refers to the id column of dictionary.function table';

comment on constraint "aggregate_final_function_id_fkey" on "dictionary"."aggregate"
  is 'Foreign key constraint for the final_function_id column, which refers to the id column of dictionary.function table';

comment on index "dictionary"."aggregate_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "aggregate_creator_id_fkey" on "dictionary"."aggregate"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "aggregate_modifier_id_fkey" on "dictionary"."aggregate"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "dictionary"."aggregate_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on index "dictionary"."aggregate_is_void_idx"
  is 'Index for the is_void column';

comment on schema "operational"
  is 'Consist the basic study, entry, plot, and subplot data, the study meta, observation data and the audit data
produced in day to day data production events (knowledge work) in the product development programs';

comment on table "operational"."study"
  is 'Studies';

comment on column "operational"."study"."id"
  is 'Locally unique primary key';

comment on column "operational"."study"."key"
  is 'Logical key of the study';

comment on column "operational"."study"."name"
  is 'Logical name of the study';

comment on column "operational"."study"."title"
  is 'Title of the study';

comment on column "operational"."study"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."study"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."study"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."study"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."study"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."study"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "operational"."study_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "study_creator_id_fkey" on "operational"."study"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "study_modifier_id_fkey" on "operational"."study"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."study_key_idx"
  is 'Index for the key column';

comment on index "operational"."study_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."study_metadata"
  is 'Metadata of a study';

comment on column "operational"."study_metadata"."id"
  is 'Locally unique primary key';

comment on column "operational"."study_metadata"."study_id"
  is 'ID referring to study';

comment on column "operational"."study_metadata"."value"
  is 'Value of a variable';

comment on column "operational"."study_metadata"."remarks"
  is 'Additional details';

comment on column "operational"."study_metadata"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."study_metadata"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."study_metadata"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."study_metadata"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."study_metadata"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."study_metadata"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "study_metadata_study_id_fkey" on "operational"."study_metadata"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "study_metadata_variable_id_fkey" on "operational"."study_metadata"
  is 'Foreign key constraint for the variable_id column, which refers to the id column of the master.variable table';

comment on index "operational"."study_metadata_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "study_metadata_creator_id_fkey" on "operational"."study_metadata"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "study_metadata_modifier_id_fkey" on "operational"."study_metadata"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."study_metadata_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."study_metadata_variable_id_idx"
  is 'Index for the variable_id column';

comment on index "operational"."study_metadata_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."entry"
  is 'Entries of a study';

comment on column "operational"."entry"."id"
  is 'Locally unique primary key';

comment on column "operational"."entry"."study_id"
  is 'ID referring to study';

comment on column "operational"."entry"."number"
  is 'Number of the entry within the study';

comment on column "operational"."entry"."key"
  is 'Logical key of the entry';

comment on column "operational"."entry"."code"
  is 'Code of the entry within the study';

comment on column "operational"."entry"."product_id"
  is 'ID of the product in the product table';

comment on column "operational"."entry"."product_gid"
  is 'ID of germplasm from the IRIS GMS database; related to the germplasm''s seed stocks';

comment on column "operational"."entry"."product_name"
  is 'Name or designation used for the product within the study';

comment on column "operational"."entry"."description"
  is 'Description';

comment on column "operational"."entry"."remarks"
  is 'Additional details';

comment on column "operational"."entry"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."entry"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."entry"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."entry"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."entry"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."entry"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "entry_study_id_fkey" on "operational"."entry"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "entry_product_id_fkey" on "operational"."entry"
  is 'Foreign key constraint for the product_id column, which refers to the id column of the master.product table';

comment on index "operational"."entry_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "entry_creator_id_fkey" on "operational"."entry"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "entry_modifier_id_fkey" on "operational"."entry"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."entry_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."entry_key_idx"
  is 'Index for the key column';

comment on index "operational"."entry_product_id_idx"
  is 'Index for the product_id column';

comment on index "operational"."entry_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."entry_metadata"
  is 'Metadata of an entry';

comment on column "operational"."entry_metadata"."id"
  is 'Locally unique primary key';

comment on column "operational"."entry_metadata"."study_id"
  is 'ID referring to study';

comment on column "operational"."entry_metadata"."entry_id"
  is 'ID referring to entry';

comment on column "operational"."entry_metadata"."value"
  is 'Value of a variable';

comment on column "operational"."entry_metadata"."remarks"
  is 'Additional details';

comment on column "operational"."entry_metadata"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."entry_metadata"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."entry_metadata"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."entry_metadata"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."entry_metadata"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."entry_metadata"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "entry_metadata_study_id_fkey" on "operational"."entry_metadata"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "entry_metadata_entry_id_fkey" on "operational"."entry_metadata"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on constraint "entry_metadata_variable_id_fkey" on "operational"."entry_metadata"
  is 'Foreign key constraint for the variable_id column, which refers to the id column of the master.variable table';

comment on index "operational"."entry_metadata_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "entry_metadata_creator_id_fkey" on "operational"."entry_metadata"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "entry_metadata_modifier_id_fkey" on "operational"."entry_metadata"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."entry_metadata_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."entry_metadata_entry_id_idx"
  is 'Index for the entry_id column';

comment on index "operational"."entry_metadata_variable_id_idx"
  is 'Index for the variable_id column';

comment on index "operational"."entry_metadata_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."entry_data"
  is 'Observational data of an entry';

comment on column "operational"."entry_data"."id"
  is 'Locally unique primary key';

comment on column "operational"."entry_data"."study_id"
  is 'ID referring to study';

comment on column "operational"."entry_data"."entry_id"
  is 'ID referring to entry';

comment on column "operational"."entry_data"."value"
  is 'Value of a variable';

comment on column "operational"."entry_data"."remarks"
  is 'Additional details';

comment on column "operational"."entry_data"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."entry_data"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."entry_data"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."entry_data"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."entry_data"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."entry_data"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "entry_data_study_id_fkey" on "operational"."entry_data"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "entry_data_entry_id_fkey" on "operational"."entry_data"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on constraint "entry_data_variable_id_fkey" on "operational"."entry_data"
  is 'Foreign key constraint for the variable_id column, which refers to the id column of the master.variable table';

comment on index "operational"."entry_data_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "entry_data_creator_id_fkey" on "operational"."entry_data"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "entry_data_modifier_id_fkey" on "operational"."entry_data"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."entry_data_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."entry_data_entry_id_idx"
  is 'Index for the entry_id column';

comment on index "operational"."entry_data_variable_id_idx"
  is 'Index for the variable_id column';

comment on index "operational"."entry_data_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."plot"
  is 'Plot of a study entry';

comment on column "operational"."plot"."id"
  is 'Locally unique primary key';

comment on column "operational"."plot"."study_id"
  is 'ID referring to study';

comment on column "operational"."plot"."entry_id"
  is 'ID referring to entry';

comment on column "operational"."plot"."replication_number"
  is 'Replication number of a plot';

comment on column "operational"."plot"."key"
  is 'Logical key of the plot';

comment on column "operational"."plot"."code"
  is 'Code of the plot within the study';

comment on column "operational"."plot"."description"
  is 'Description';

comment on column "operational"."plot"."remarks"
  is 'Additional details';

comment on column "operational"."plot"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."plot"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."plot"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."plot"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."plot"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."plot"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "plot_study_id_fkey" on "operational"."plot"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "plot_entry_id_fkey" on "operational"."plot"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on index "operational"."plot_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "plot_creator_id_fkey" on "operational"."plot"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "plot_modifier_id_fkey" on "operational"."plot"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."plot_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."plot_entry_id_idx"
  is 'Index for the entry_id column';

comment on index "operational"."plot_key_idx"
  is 'Index for the key column';

comment on index "operational"."plot_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."plot_metadata"
  is 'Metadata of a plot';

comment on column "operational"."plot_metadata"."id"
  is 'Locally unique primary key';

comment on column "operational"."plot_metadata"."study_id"
  is 'ID referring to study';

comment on column "operational"."plot_metadata"."entry_id"
  is 'ID referring to entry';

comment on column "operational"."plot_metadata"."plot_id"
  is 'ID referring to plot';

comment on column "operational"."plot_metadata"."value"
  is 'Value of a variable';

comment on column "operational"."plot_metadata"."remarks"
  is 'Additional details';

comment on column "operational"."plot_metadata"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."plot_metadata"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."plot_metadata"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."plot_metadata"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."plot_metadata"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."plot_metadata"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "plot_metadata_study_id_fkey" on "operational"."plot_metadata"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "plot_metadata_entry_id_fkey" on "operational"."plot_metadata"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on constraint "plot_metadata_plot_id_fkey" on "operational"."plot_metadata"
  is 'Foreign key constraint for the plot_id column, which refers to the id column of the plot table';

comment on constraint "plot_metadata_variable_id_fkey" on "operational"."plot_metadata"
  is 'Foreign key constraint for the variable_id column, which refers to the id column of the master.variable table';

comment on index "operational"."plot_metadata_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "plot_metadata_creator_id_fkey" on "operational"."plot_metadata"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "plot_metadata_modifier_id_fkey" on "operational"."plot_metadata"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."plot_metadata_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."plot_metadata_entry_id_idx"
  is 'Index for the entry_id column';

comment on index "operational"."plot_metadata_plot_id_idx"
  is 'Index for the plot_id column';

comment on index "operational"."plot_metadata_variable_id_idx"
  is 'Index for the variable_id column';

comment on index "operational"."plot_metadata_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."plot_data"
  is 'Observational data of a plot';

comment on column "operational"."plot_data"."id"
  is 'Locally unique primary key';

comment on column "operational"."plot_data"."study_id"
  is 'ID referring to study';

comment on column "operational"."plot_data"."entry_id"
  is 'ID referring to entry';

comment on column "operational"."plot_data"."plot_id"
  is 'ID referring to plot';

comment on column "operational"."plot_data"."value"
  is 'Value of a variable';

comment on column "operational"."plot_data"."remarks"
  is 'Additional details';

comment on column "operational"."plot_data"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."plot_data"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."plot_data"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."plot_data"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."plot_data"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."plot_data"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "plot_data_study_id_fkey" on "operational"."plot_data"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "plot_data_entry_id_fkey" on "operational"."plot_data"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on constraint "plot_data_plot_id_fkey" on "operational"."plot_data"
  is 'Foreign key constraint for the plot_id column, which refers to the id column of the plot table';

comment on constraint "plot_data_variable_id_fkey" on "operational"."plot_data"
  is 'Foreign key constraint for the variable_id column, which refers to the id column of the master.variable table';

comment on index "operational"."plot_data_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "plot_data_creator_id_fkey" on "operational"."plot_data"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "plot_data_modifier_id_fkey" on "operational"."plot_data"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."plot_data_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."plot_data_entry_id_idx"
  is 'Index for the entry_id column';

comment on index "operational"."plot_data_plot_id_idx"
  is 'Index for the plot_id column';

comment on index "operational"."plot_data_variable_id_idx"
  is 'Index for the variable_id column';

comment on index "operational"."plot_data_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."subplot"
  is 'Subplot of a study entry''s plot';

comment on column "operational"."subplot"."id"
  is 'Locally unique primary key';

comment on column "operational"."subplot"."study_id"
  is 'ID referring to study';

comment on column "operational"."subplot"."entry_id"
  is 'ID referring to entry';

comment on column "operational"."subplot"."plot_id"
  is 'ID referring to plot';

comment on column "operational"."subplot"."number"
  is 'Number of the subplot within the plot';

comment on column "operational"."subplot"."key"
  is 'Logical key of the subplot';

comment on column "operational"."subplot"."description"
  is 'Description';

comment on column "operational"."subplot"."remarks"
  is 'Additional details';

comment on column "operational"."subplot"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."subplot"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."subplot"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."subplot"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."subplot"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."subplot"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "subplot_study_id_fkey" on "operational"."subplot"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "subplot_entry_id_fkey" on "operational"."subplot"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on constraint "subplot_plot_id_fkey" on "operational"."subplot"
  is 'Foreign key constraint for the plot_id column, which refers to the id column of the plot table';

comment on index "operational"."subplot_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "subplot_creator_id_fkey" on "operational"."subplot"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "subplot_modifier_id_fkey" on "operational"."subplot"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."subplot_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."subplot_entry_id_idx"
  is 'Index for the entry_id column';

comment on index "operational"."subplot_plot_id_idx"
  is 'Index for the plot_id column';

comment on index "operational"."subplot_key_idx"
  is 'Index for the key column';

comment on index "operational"."subplot_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."subplot_metadata"
  is 'Metadata of a subplot';

comment on column "operational"."subplot_metadata"."id"
  is 'Locally unique primary key';

comment on column "operational"."subplot_metadata"."study_id"
  is 'ID referring to study';

comment on column "operational"."subplot_metadata"."entry_id"
  is 'ID referring to entry';

comment on column "operational"."subplot_metadata"."plot_id"
  is 'ID referring to plot';

comment on column "operational"."subplot_metadata"."subplot_id"
  is 'ID referring to subplot';

comment on column "operational"."subplot_metadata"."value"
  is 'Value of a variable';

comment on column "operational"."subplot_metadata"."remarks"
  is 'Additional details';

comment on column "operational"."subplot_metadata"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."subplot_metadata"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."subplot_metadata"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."subplot_metadata"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."subplot_metadata"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."subplot_metadata"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "subplot_metadata_study_id_fkey" on "operational"."subplot_metadata"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "subplot_metadata_entry_id_fkey" on "operational"."subplot_metadata"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on constraint "subplot_metadata_plot_id_fkey" on "operational"."subplot_metadata"
  is 'Foreign key constraint for the plot_id column, which refers to the id column of the plot table';

comment on constraint "subplot_metadata_subplot_id_fkey" on "operational"."subplot_metadata"
  is 'Foreign key constraint for the subplot_id column, which refers to the id column of the subplot table';

comment on constraint "subplot_metadata_variable_id_fkey" on "operational"."subplot_metadata"
  is 'Foreign key constraint for the variable_id column, which refers to the id column of the master.variable table';

comment on index "operational"."subplot_metadata_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "subplot_metadata_creator_id_fkey" on "operational"."subplot_metadata"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "subplot_metadata_modifier_id_fkey" on "operational"."subplot_metadata"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."subplot_metadata_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."subplot_metadata_entry_id_idx"
  is 'Index for the entry_id column';

comment on index "operational"."subplot_metadata_plot_id_idx"
  is 'Index for the plot_id column';

comment on index "operational"."subplot_metadata_subplot_id_idx"
  is 'Index for the subplot_id column';

comment on index "operational"."subplot_metadata_variable_id_idx"
  is 'Index for the variable_id column';

comment on index "operational"."subplot_metadata_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."subplot_data"
  is 'Observational data of a subplot';

comment on column "operational"."subplot_data"."id"
  is 'Locally unique primary key';

comment on column "operational"."subplot_data"."study_id"
  is 'ID referring to study';

comment on column "operational"."subplot_data"."entry_id"
  is 'ID referring to entry';

comment on column "operational"."subplot_data"."plot_id"
  is 'ID referring to plot';

comment on column "operational"."subplot_data"."subplot_id"
  is 'ID referring to subplot';

comment on column "operational"."subplot_data"."value"
  is 'Value of a variable';

comment on column "operational"."subplot_data"."remarks"
  is 'Additional details';

comment on column "operational"."subplot_data"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."subplot_data"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."subplot_data"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."subplot_data"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."subplot_data"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."subplot_data"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "subplot_data_study_id_fkey" on "operational"."subplot_data"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "subplot_data_entry_id_fkey" on "operational"."subplot_data"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on constraint "subplot_data_plot_id_fkey" on "operational"."subplot_data"
  is 'Foreign key constraint for the plot_id column, which refers to the id column of the plot table';

comment on constraint "subplot_data_subplot_id_fkey" on "operational"."subplot_data"
  is 'Foreign key constraint for the subplot_id column, which refers to the id column of the subplot table';

comment on constraint "subplot_data_variable_id_fkey" on "operational"."subplot_data"
  is 'Foreign key constraint for the variable_id column, which refers to the id column of the master.variable table';

comment on index "operational"."subplot_data_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "subplot_data_creator_id_fkey" on "operational"."subplot_data"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "subplot_data_modifier_id_fkey" on "operational"."subplot_data"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."subplot_data_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."subplot_data_entry_id_idx"
  is 'Index for the entry_id column';

comment on index "operational"."subplot_data_plot_id_idx"
  is 'Index for the plot_id column';

comment on index "operational"."subplot_data_subplot_id_idx"
  is 'Index for the subplot_id column';

comment on index "operational"."subplot_data_variable_id_idx"
  is 'Index for the variable_id column';

comment on index "operational"."subplot_data_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."cross"
  is 'Crosses in a crossing study in the hybridization (HB) phase';

comment on column "operational"."cross"."id"
  is 'Locally unique primary key';

comment on column "operational"."cross"."study_id"
  is 'ID referring to study';

comment on column "operational"."cross"."female_entry_id"
  is 'ID of the female entry in the cross';

comment on column "operational"."cross"."female_product_id"
  is 'ID of the female product in the cross';

comment on column "operational"."cross"."female_product_name"
  is 'Name or designation used for the female product in the cross';

comment on column "operational"."cross"."male_entry_id"
  is 'ID of the male entry in the cross';

comment on column "operational"."cross"."male_product_id"
  is 'ID of the male product in the cross';

comment on column "operational"."cross"."male_product_name"
  is 'Name or designation used for the male product in the cross';

comment on column "operational"."cross"."description"
  is 'Description';

comment on column "operational"."cross"."remarks"
  is 'Additional details';

comment on column "operational"."cross"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."cross"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."cross"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."cross"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."cross"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."cross"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "cross_female_entry_id_fkey" on "operational"."cross"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on constraint "cross_female_product_id_fkey" on "operational"."cross"
  is 'Foreign key constraint for the product_id column, which refers to the id column of the master.product table';

comment on constraint "cross_male_entry_id_fkey" on "operational"."cross"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on constraint "cross_male_product_id_fkey" on "operational"."cross"
  is 'Foreign key constraint for the product_id column, which refers to the id column of the master.product table';

comment on constraint "cross_cross_method_id_fkey" on "operational"."cross"
  is 'Foreign key constraint for the cross_method_id column, which refers to the id column of the master.cross_method table';

comment on index "operational"."cross_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "cross_creator_id_fkey" on "operational"."cross"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "cross_modifier_id_fkey" on "operational"."cross"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."cross_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."cross_female_entry_id_idx"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on index "operational"."cross_female_product_id_idx"
  is 'Foreign key constraint for the product_id column, which refers to the id column of the master.product table';

comment on index "operational"."cross_male_entry_id_idx"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on index "operational"."cross_male_product_id_idx"
  is 'Foreign key constraint for the product_id column, which refers to the id column of the master.product table';

comment on table "operational"."cross_metadata"
  is 'Metadata about a cross';

comment on column "operational"."cross_metadata"."id"
  is 'Locally unique primary key';

comment on column "operational"."cross_metadata"."study_id"
  is 'ID referring to study';

comment on column "operational"."cross_metadata"."value"
  is 'Value of a variable';

comment on column "operational"."cross_metadata"."remarks"
  is 'Additional details';

comment on column "operational"."cross_metadata"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."cross_metadata"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."cross_metadata"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."cross_metadata"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."cross_metadata"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."cross_metadata"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "cross_metadata_study_id_fkey" on "operational"."cross_metadata"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "cross_metadata_variable_id_fkey" on "operational"."cross_metadata"
  is 'Foreign key constraint for the variable_id column, which refers to the id column of the master.variable table';

comment on index "operational"."cross_metadata_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "cross_metadata_creator_id_fkey" on "operational"."cross_metadata"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "cross_metadata_modifier_id_fkey" on "operational"."cross_metadata"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."cross_metadata_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."cross_metadata_variable_id_idx"
  is 'Index for the variable_id column';

comment on index "operational"."cross_metadata_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."cross_data"
  is 'Observational data of a cross';

comment on column "operational"."cross_data"."id"
  is 'Locally unique primary key';

comment on column "operational"."cross_data"."study_id"
  is 'ID referring to study';

comment on column "operational"."cross_data"."value"
  is 'Value of a variable';

comment on column "operational"."cross_data"."remarks"
  is 'Additional details';

comment on column "operational"."cross_data"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."cross_data"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."cross_data"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."cross_data"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."cross_data"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."cross_data"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "cross_data_study_id_fkey" on "operational"."cross_data"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "cross_data_variable_id_fkey" on "operational"."cross_data"
  is 'Foreign key constraint for the variable_id column, which refers to the id column of the master.variable table';

comment on index "operational"."cross_data_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "cross_data_creator_id_fkey" on "operational"."cross_data"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "cross_data_modifier_id_fkey" on "operational"."cross_data"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."cross_data_study_id_idx"
  is 'Index for the study_id column';

comment on index "operational"."cross_data_variable_id_idx"
  is 'Index for the variable_id column';

comment on index "operational"."cross_data_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."seed_storage"
  is 'Seed storage contains the product storage units. This gives information
on what material is available to be used in the product development programs.';

comment on column "operational"."seed_storage"."id"
  is 'Locally unique primary key';

comment on column "operational"."seed_storage"."product_id"
  is 'Product where the seeds are harvested from';

comment on column "operational"."seed_storage"."seed_lot_id"
  is 'A unique identifier for the seed storage assigned by the data manager';

comment on column "operational"."seed_storage"."key_type"
  is 'family id, entry key, plot key, custom key, seed_lot_id';

comment on column "operational"."seed_storage"."seed_manager"
  is 'Refers to which product development programs has access to the seeds';

comment on column "operational"."seed_storage"."label"
  is 'Metadata about the seed storage';

comment on column "operational"."seed_storage"."original_storage_id"
  is 'Null except in special cases when a seed lot is divided into several seed lots,
this contains the seed storage ID of the original seed lot that was divided';

comment on column "operational"."seed_storage"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."seed_storage"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."seed_storage"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."seed_storage"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."seed_storage"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."seed_storage"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "operational"."seed_storage_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "seed_storage_creator_id_fkey" on "operational"."seed_storage"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "seed_storage_modifier_id_fkey" on "operational"."seed_storage"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."seed_storage_is_void_idx"
  is 'Index for the is_void column';

comment on table "operational"."seed_storage_log"
  is 'Transaction log contains the history of transactions made';

comment on column "operational"."seed_storage_log"."id"
  is 'Locally unique primary key';

comment on column "operational"."seed_storage_log"."encoder_id"
  is 'User who entered the record';

comment on column "operational"."seed_storage_log"."encode_timestamp"
  is 'Timestamp when the transaction was done';

comment on column "operational"."seed_storage_log"."transaction_type"
  is 'Deposit or withdraw';

comment on column "operational"."seed_storage_log"."event_timestamp"
  is 'Timestamp when the transaction was needed';

comment on column "operational"."seed_storage_log"."sender"
  is 'Where the deposited seeds come from';

comment on column "operational"."seed_storage_log"."receiver"
  is 'Where the withdrawn seeds will go to';

comment on column "operational"."seed_storage_log"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "operational"."seed_storage_log"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "operational"."seed_storage_log"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "operational"."seed_storage_log"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "operational"."seed_storage_log"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "operational"."seed_storage_log"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "operational"."seed_storage_log_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "seed_storage_log_creator_id_fkey" on "operational"."seed_storage_log"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "seed_storage_log_modifier_id_fkey" on "operational"."seed_storage_log"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "operational"."seed_storage_log_is_void_idx"
  is 'Index for the is_void column';

comment on schema "warehouse"
  is 'Validated data from the operational schema';

comment on table "warehouse"."study"
  is 'Studies';

comment on column "warehouse"."study"."id"
  is 'Locally unique primary key';

comment on column "warehouse"."study"."key"
  is 'Logical key of the study';

comment on column "warehouse"."study"."name"
  is 'Logical name of the study';

comment on column "warehouse"."study"."title"
  is 'Title of the study';

comment on column "warehouse"."study"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "warehouse"."study"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "warehouse"."study"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "warehouse"."study"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "warehouse"."study"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "warehouse"."study"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on index "warehouse"."study_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "study_creator_id_fkey" on "warehouse"."study"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "study_modifier_id_fkey" on "warehouse"."study"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "warehouse"."study_key_idx"
  is 'Index for the key column';

comment on index "warehouse"."study_is_void_idx"
  is 'Index for the is_void column';

comment on table "warehouse"."entry"
  is 'Entries of a study';

comment on column "warehouse"."entry"."id"
  is 'Locally unique primary key';

comment on column "warehouse"."entry"."study_id"
  is 'ID referring to study';

comment on column "warehouse"."entry"."number"
  is 'Number of the entry within the study';

comment on column "warehouse"."entry"."key"
  is 'Logical key of the entry';

comment on column "warehouse"."entry"."code"
  is 'Code of the entry within the study';

comment on column "warehouse"."entry"."product_id"
  is 'ID of the product in the product table';

comment on column "warehouse"."entry"."product_gid"
  is 'ID of germplasm from the IRIS GMS database; related to the germplasm''s seed stocks';

comment on column "warehouse"."entry"."product_name"
  is 'Name or designation used for the product within the study';

comment on column "warehouse"."entry"."description"
  is 'Description';

comment on column "warehouse"."entry"."remarks"
  is 'Additional details';

comment on column "warehouse"."entry"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "warehouse"."entry"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "warehouse"."entry"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "warehouse"."entry"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "warehouse"."entry"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "warehouse"."entry"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "entry_study_id_fkey" on "warehouse"."entry"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "entry_product_id_fkey" on "warehouse"."entry"
  is 'Foreign key constraint for the product_id column, which refers to the id column of the master.product table';

comment on index "warehouse"."entry_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "entry_creator_id_fkey" on "warehouse"."entry"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "entry_modifier_id_fkey" on "warehouse"."entry"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "warehouse"."entry_study_id_idx"
  is 'Index for the study_id column';

comment on index "warehouse"."entry_key_idx"
  is 'Index for the key column';

comment on index "warehouse"."entry_product_id_idx"
  is 'Index for the product_id column';

comment on index "warehouse"."entry_is_void_idx"
  is 'Index for the is_void column';

comment on table "warehouse"."plot"
  is 'Plot of a study entry';

comment on column "warehouse"."plot"."id"
  is 'Locally unique primary key';

comment on column "warehouse"."plot"."study_id"
  is 'ID referring to study';

comment on column "warehouse"."plot"."entry_id"
  is 'ID referring to entry';

comment on column "warehouse"."plot"."replication_number"
  is 'Replication number of a plot';

comment on column "warehouse"."plot"."key"
  is 'Logical key of the plot';

comment on column "warehouse"."plot"."code"
  is 'Code of the plot within the study';

comment on column "warehouse"."plot"."description"
  is 'Description';

comment on column "warehouse"."plot"."remarks"
  is 'Additional details';

comment on column "warehouse"."plot"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "warehouse"."plot"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "warehouse"."plot"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "warehouse"."plot"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "warehouse"."plot"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "warehouse"."plot"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "plot_study_id_fkey" on "warehouse"."plot"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "plot_entry_id_fkey" on "warehouse"."plot"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on index "warehouse"."plot_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "plot_creator_id_fkey" on "warehouse"."plot"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "plot_modifier_id_fkey" on "warehouse"."plot"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "warehouse"."plot_study_id_idx"
  is 'Index for the study_id column';

comment on index "warehouse"."plot_entry_id_idx"
  is 'Index for the entry_id column';

comment on index "warehouse"."plot_key_idx"
  is 'Index for the key column';

comment on index "warehouse"."plot_is_void_idx"
  is 'Index for the is_void column';

comment on table "warehouse"."subplot"
  is 'Subplot of a study entry''s plot';

comment on column "warehouse"."subplot"."id"
  is 'Locally unique primary key';

comment on column "warehouse"."subplot"."study_id"
  is 'ID referring to study';

comment on column "warehouse"."subplot"."entry_id"
  is 'ID referring to entry';

comment on column "warehouse"."subplot"."plot_id"
  is 'ID referring to plot';

comment on column "warehouse"."subplot"."number"
  is 'Number of the subplot within the plot';

comment on column "warehouse"."subplot"."key"
  is 'Logical key of the subplot';

comment on column "warehouse"."subplot"."description"
  is 'Description';

comment on column "warehouse"."subplot"."remarks"
  is 'Additional details';

comment on column "warehouse"."subplot"."creation_timestamp"
  is 'Timestamp when the record was added to the table';

comment on column "warehouse"."subplot"."creator_id"
  is 'ID of the user who added the record to the table';

comment on column "warehouse"."subplot"."modification_timestamp"
  is 'Timestamp when the record was last modified';

comment on column "warehouse"."subplot"."modifier_id"
  is 'ID of the user who last modified the record';

comment on column "warehouse"."subplot"."notes"
  is 'Additional details added by an admin; can be technical or advanced details';

comment on column "warehouse"."subplot"."is_void"
  is 'Indicator whether the record is deleted or not';

comment on constraint "subplot_study_id_fkey" on "warehouse"."subplot"
  is 'Foreign key constraint for the study_id column, which refers to the id column of the study table';

comment on constraint "subplot_entry_id_fkey" on "warehouse"."subplot"
  is 'Foreign key constraint for the entry_id column, which refers to the id column of the entry table';

comment on constraint "subplot_plot_id_fkey" on "warehouse"."subplot"
  is 'Foreign key constraint for the plot_id column, which refers to the id column of the plot table';

comment on index "warehouse"."subplot_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "subplot_creator_id_fkey" on "warehouse"."subplot"
  is 'Foreign key constraint for the creator_id column, which refers to the id column of master.user table';

comment on constraint "subplot_modifier_id_fkey" on "warehouse"."subplot"
  is 'Foreign key constraint for the modifier_id column, which refers to the id column of the master.user table';

comment on index "warehouse"."subplot_study_id_idx"
  is 'Index for the study_id column';

comment on index "warehouse"."subplot_entry_id_idx"
  is 'Index for the entry_id column';

comment on index "warehouse"."subplot_plot_id_idx"
  is 'Index for the plot_id column';

comment on index "warehouse"."subplot_key_idx"
  is 'Index for the key column';

comment on index "warehouse"."subplot_is_void_idx"
  is 'Index for the is_void column';



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

insert into "master"."program" (
    "abbrev",
    "name",
    "description"
) values (
    'IRRSEA',
    'Irrigated South-East Asia',
    'Irrigated South-East Asia'
);

insert into "master"."place" (
    "abbrev",
    "name",
    "description"
) values (
    'PHLB',
    'Los Banos, Philippines',
    'Los Banos, Philippines'
);

insert into "master"."phase" (
    "abbrev",
    "name",
    "description"
) values (
    'OYT',
    'Observation Yield Trial',
    'Observation Yield Trial'
), (
    'RYT',
    'Replicated Yield Trial',
    'Replicated Yield Trial'
), (
    'AYT',
    'Advanced Yield Trial',
    'Advanced Yield Trial'
), (
    'MET',
    'Multi-Environment Yield Trial',
    'Multi-Environment Yield Trial'
);

insert into "master"."season" (
    "abbrev",
    "name",
    "description"
) values (
    'DS',
    'Dry',
    'Dry season'
), (
    'WS',
    'Wet',
    'Wet season'
), (
    'CS',
    'Custom',
    'Custom season'
);

insert into "master"."place_season" (
    "place_id",
    "season_id",
    "order_number"
) values (
    '1',
    '1',
    '1'
), (
    '1',
    '2',
    '2'
), (
    '1',
    '3',
    '3'
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

-- ---------------------------------------------------

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
    -- order by
        -- lower(trim(iv."name")) asc,
        -- count(iv.id) desc
) var
;

-- ---------------------------------------------------

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
        iv.id
    -- order by
        -- trim(iv.method) asc
) var
;

-- ---------------------------------------------------

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
        iv.id
    -- order by
        -- trim(iv.scale) asc
) var
;

-- ---------------------------------------------------

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
        iv.iv_id,

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
            iv.id iv_id,
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
    -- order by
        -- property_id,
        -- method_id,
        -- scale_id
) var
order by
    var.iv_id
;

-- ---------------------------------------------------

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

-- ---------------------------------------------------

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

-- ---------------------------------------------------

