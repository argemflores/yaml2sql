create database "bims_0.10"
    encoding = 'UTF8'
    lc_collate = 'C'
    lc_ctype = 'C';

create schema "master";

create table "master"."user" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null,
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
    "user_type" integer not null
) with (
    oids = false
);

alter table "master"."user"
  add constraint "user_id_pkey"
  primary key ("id");
alter table "master"."user"
  add constraint "user_creator_id_fkey"
  foreign key ("creator_id")
  references "master"."user" ("id") match simple;
alter table "master"."user"
  add constraint "user_modifier_id_fkey"
  foreign key ("modifier_id")
  references "master"."user" ("id") match simple;

create unique index "user_abbrev_idx"
  on "master"."user"
  using btree ("abbrev");
create unique index "user_email_idx"
  on "master"."user"
  using btree ("email");
create unique index "user_username_idx"
  on "master"."user"
  using btree ("username");

create table "master"."program" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
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
  foreign key ("creator_id")
  references "master"."user" ("id") match simple;
alter table "master"."program"
  add constraint "program_modifier_id_fkey"
  foreign key ("modifier_id")
  references "master"."user" ("id") match simple;

create unique index "program_abbrev_idx"
  on "master"."program"
  using btree ("abbrev");

create table "master"."place" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
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
  foreign key ("creator_id")
  references "master"."user" ("id") match simple;
alter table "master"."place"
  add constraint "place_modifier_id_fkey"
  foreign key ("modifier_id")
  references "master"."user" ("id") match simple;

create unique index "place_abbrev_idx"
  on "master"."place"
  using btree ("abbrev");

create table "master"."phase" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
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
  foreign key ("creator_id")
  references "master"."user" ("id") match simple;
alter table "master"."phase"
  add constraint "phase_modifier_id_fkey"
  foreign key ("modifier_id")
  references "master"."user" ("id") match simple;

create unique index "phase_abbrev_idx"
  on "master"."phase"
  using btree ("abbrev");

create table "master"."product" (
    "id" serial not null,
    "abbrev" varchar(128) not null,
    "name" varchar(128) not null,
    "description" text,
    "creation_timestamp" timestamp not null,
    "creator_id" integer not null,
    "modification_timestamp" timestamp not null,
    "modifier_id" integer not null,
    "notes" text,
    "is_void" boolean not null,
    "gid" integer not null,
    "type" varchar not null,
    "authority" varchar not null,
    "generation" integer,
    "iris_preferred_id" varchar,
    "breeding_line_name_id" varchar,
    "fixed_line_name" varchar,
    "common_name" varchar,
    "cultivar_name" varchar
) with (
    oids = false
);

alter table "master"."product"
  add constraint "product_id_pkey"
  primary key ("id");
alter table "master"."product"
  add constraint "product_creator_id_fkey"
  foreign key ("creator_id")
  references "master"."user" ("id") match simple;
alter table "master"."product"
  add constraint "product_modifier_id_fkey"
  foreign key ("modifier_id")
  references "master"."user" ("id") match simple;

create unique index "product_abbrev_idx"
  on "master"."product"
  using btree ("abbrev");

comment on database "bims_0.10"
  is 'BIMS: Breeding Information Management System';

comment on schema "master"
  is 'Stores master data, which are absolutely correct and does not change frequently';

comment on table "master"."user"
  is 'Users';

comment on column "master"."user"."id"
  is 'Locally unique primary key';

comment on column "master"."user"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."user"."name"
  is 'Name identifier';

comment on column "master"."user"."description"
  is 'Description';

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
  is 'Foreign key constraint for the creator_id column, which refers to the master.user.id table';

comment on constraint "user_modifier_id_fkey" on "master"."user"
  is 'Foreign key constraint for the modifier_id column, which refers to the master.user.id table';

comment on index "master"."user_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on table "master"."program"
  is 'Programs for product-development profiles';

comment on column "master"."program"."id"
  is 'Locally unique primary key';

comment on column "master"."program"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."program"."name"
  is 'Name identifier';

comment on column "master"."program"."description"
  is 'Description';

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
  is 'Foreign key constraint for the creator_id column, which refers to the master.user.id table';

comment on constraint "program_modifier_id_fkey" on "master"."program"
  is 'Foreign key constraint for the modifier_id column, which refers to the master.user.id table';

comment on index "master"."program_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on table "master"."place"
  is 'Places and locations';

comment on column "master"."place"."id"
  is 'Locally unique primary key';

comment on column "master"."place"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."place"."name"
  is 'Name identifier';

comment on column "master"."place"."description"
  is 'Description';

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
  is 'Foreign key constraint for the creator_id column, which refers to the master.user.id table';

comment on constraint "place_modifier_id_fkey" on "master"."place"
  is 'Foreign key constraint for the modifier_id column, which refers to the master.user.id table';

comment on index "master"."place_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on table "master"."phase"
  is 'Breeding phases';

comment on column "master"."phase"."id"
  is 'Locally unique primary key';

comment on column "master"."phase"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."phase"."name"
  is 'Name identifier';

comment on column "master"."phase"."description"
  is 'Description';

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

comment on column "master"."phase"."order_no"
  is 'Ordering number';

comment on index "master"."phase_id_pkey"
  is 'Primary key constraint for the id column';

comment on constraint "phase_creator_id_fkey" on "master"."phase"
  is 'Foreign key constraint for the creator_id column, which refers to the master.user.id table';

comment on constraint "phase_modifier_id_fkey" on "master"."phase"
  is 'Foreign key constraint for the modifier_id column, which refers to the master.user.id table';

comment on index "master"."phase_abbrev_idx"
  is 'Unique index for the abbrev column';

comment on table "master"."product"
  is 'Product catalog';

comment on column "master"."product"."id"
  is 'Locally unique primary key';

comment on column "master"."product"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."product"."name"
  is 'Name identifier';

comment on column "master"."product"."description"
  is 'Description';

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
  is 'Foreign key constraint for the creator_id column, which refers to the master.user.id table';

comment on constraint "product_modifier_id_fkey" on "master"."product"
  is 'Foreign key constraint for the modifier_id column, which refers to the master.user.id table';

comment on index "master"."product_abbrev_idx"
  is 'Unique index for the abbrev column';
