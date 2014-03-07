create database "bims_0.10"
    encoding = 'UTF8'
    lc_collate = 'C'
    lc_ctype = 'C';

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
    "status" varchar not null,
    "salutation" varchar(16),
    "valid_start_date" date,
    "valid_end_date" date,
    "user_type" integer not null,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "description" varchar,
    "order_no" integer not null default '1',
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "master"."scale_value"
  add constraint "scale_value_scale_id_fkey_cst"
  foreign key ("scale_id") references "master"."scale" ("id")
  match simple on update cascade on delete cascade;
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
    "type" varchar,
    "data_type" varchar,
    "property_id" integer,
    "method_id" integer,
    "scale_id" integer,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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

create table "master"."pipeline" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null,
    "order_no" integer not null default '1'
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
    "breeding_line_name_id" varchar,
    "fixed_line_name" varchar,
    "common_name" varchar,
    "cultivar_name" varchar,
    "description" text,
    "remarks" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "variable_value" varchar not null,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

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

create unique index "product_metadata_abbrev_idx"
  on "master"."product_metadata"
  using btree ("abbrev");
create index "product_metadata_is_void_idx"
  on "master"."product_metadata"
  using btree ("is_void");

