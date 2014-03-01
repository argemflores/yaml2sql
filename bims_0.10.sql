create database "bims_0.10"
    encoding = 'UTF8'
    lc_collate = 'C'
    lc_ctype = 'C';

create schema "master";
comment on schema "master"
    is 'Stores master data, which are absolutely correct and does not change frequently';

create table "master"."pipeline" (
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

alter table "master"."pipeline"
  add constraint "pipeline_id_pkey"
  primary key ("id");

create unique index "master_pipeline_abbrev_idx"
  on "master"."pipeline"
  using btree ("abbrev");

comment on database "bims_0.10"
  is 'BIMS: Breeding Information Management System';

comment on schema "master"
  is 'Stores master data, which are absolutely correct and does not change frequently';

comment on table "master"."pipeline"
  is 'Pipeline';

comment on column "master"."pipeline"."id"
  is 'Locally unique primary key';

comment on column "master"."pipeline"."abbrev"
  is 'Short name identifier or abbreviation';

comment on column "master"."pipeline"."name"
  is 'Name identifier';

comment on column "master"."pipeline"."description"
  is 'Description';

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

comment on constraint "pipeline_id_pkey" on "master"."pipeline"
  is 'Primary key constraint for the id column';

comment on index "master_pipeline_abbrev_idx"
  is 'Unique index for the abbrev column';
