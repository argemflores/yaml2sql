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
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
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
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."table"
  add constraint "table_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."table"
  add constraint "table_schema_id_fkey"
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
    "not_null" boolean not null,
    "default_value" varchar,
    "comment" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."column"
  add constraint "column_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."column"
  add constraint "column_schema_id_fkey"
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
    "comment" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."constraint"
  add constraint "constraint_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."constraint"
  add constraint "constraint_schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."constraint"
  add constraint "constraint_table_id_fkey"
  foreign key ("table_id") references "dictionary"."table" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."constraint"
  add constraint "constraint_column_id_fkey"
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
    "unique" boolean not null,
    "concurrent" boolean not null,
    "comment" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."index"
  add constraint "index_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."index"
  add constraint "index_schema_id_fkey"
  foreign key ("schema_id") references "dictionary"."schema" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."index"
  add constraint "index_table_id_fkey"
  foreign key ("table_id") references "dictionary"."table" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."index"
  add constraint "index_column_id_fkey"
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
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."rule"
  add constraint "rule_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."rule"
  add constraint "rule_schema_id_fkey"
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
    "enabled" boolean not null default '1',
    "execution" varchar not null default 'before',
    "for_each" varchar not null default 'row',
    "event" varchar(16) not null default 'insert',
    "function" varchar not null,
    "argument" varchar,
    "condition" varchar,
    "comment" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."trigger"
  add constraint "trigger_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."trigger"
  add constraint "trigger_schema_id_fkey"
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
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."view"
  add constraint "view_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."view"
  add constraint "view_schema_id_fkey"
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
    "cycle" boolean not null,
    "comment" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."sequence"
  add constraint "sequence_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."sequence"
  add constraint "sequence_schema_id_fkey"
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
    "strict" boolean not null,
    "execution_privileges" varchar not null default 'invoker',
    "stability" varchar not null default 'volatile',
    "comment" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."function"
  add constraint "function_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."function"
  add constraint "function_schema_id_fkey"
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
    "data_type" varchar(32) not null,
    "not_null" boolean not null,
    "default_value" varchar,
    "collation" varchar not null default 'pg_catalog.C',
    "comment" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."domain"
  add constraint "domain_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."domain"
  add constraint "domain_schema_id_fkey"
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
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null
) with (
    oids = false
);

alter table "dictionary"."aggregate"
  add constraint "aggregate_database_id_fkey"
  foreign key ("database_id") references "dictionary"."database" ("id")
  match simple on update cascade on delete cascade;
alter table "dictionary"."aggregate"
  add constraint "aggregate_schema_id_fkey"
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

