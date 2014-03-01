create database "yaml2sql"
    encoding = 'UTF8'
    lc_collate = 'C'
    lc_ctype = 'C';

create schema "master";
comment on schema "master"
    is 'Master schema';

create schema "develop";
comment on schema "develop"
    is 'Develop schema';

create table "develop"."user" (
    "id" serial not null,
    "username" varchar not null,
    "email" varchar not null
) with (
    oids = false
);

alter table "develop"."user"
  add constraint "user_id_pkey"
  primary key ("id");

create unique index "user_email_idx"
  on "develop"."user"
  using btree ("email");

create table "develop"."commit" (
    "id" serial not null,
    "stage" varchar not null default '*',
    "message" text not null,
    "commit_timestamp" timestamp not null default now(),
    "committer_id" integer not null
) with (
    oids = false
);

alter table "develop"."commit"
  add constraint "commit_id_pkey"
  primary key ("id");
alter table "develop"."commit"
  add constraint "commit_committer_id_fkey"
  foreign key ("committer_id")
  references "develop"."user" ("id") match simple;

comment on database "yaml2sql"
  is 'YAML to SQL Database';

comment on schema "master"
  is 'Master schema';

comment on schema "develop"
  is 'Develop schema';

comment on table "develop"."user"
  is 'Users';

comment on column "develop"."user"."id"
  is 'Primary key';

comment on constraint "user_id_pkey" on "develop"."user"
  is 'Primary key constraint';

comment on index "user_email_idx"
  is 'User email unique index';

comment on table "develop"."commit"
  is 'Commit table';

comment on column "develop"."commit"."id"
  is 'Primary key';

comment on column "develop"."commit"."stage"
  is 'Stage area';

comment on column "develop"."commit"."message"
  is 'Message area';

comment on constraint "commit_id_pkey" on "develop"."commit"
  is 'Primary key constraint';

comment on constraint "commit_committer_id_fkey" on "develop"."commit"
  is 'Foreign key constraint';