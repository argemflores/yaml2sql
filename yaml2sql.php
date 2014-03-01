<?php

/**
 * yaml2sql.php
 * Author: Argem Gerald R. Flores <argemgrflores@gmail.com>
 * Creation date: 2014-03-01 10:00
 */

# require Spyc yaml loader/dumper
require_once 'Spyc.php';

# input yaml file
$inputFile = 'input.yaml';

# load input file and convert yaml contents to array, then to object
$input = json_decode(json_encode(Spyc::YAMLLoad($inputFile)));

$sql = '';

if (!empty($input->database)) {
    $database = $input->database;

    $dbSql = strtr(
<<<EOD
create database "{dbName}"
    encoding = '{dbEncoding}'
    lc_collate = '{dbLcCollate}'
    lc_ctype = '{dbLcCtype}'
;
EOD
        , [
            '{dbName}' => pg_escape_string($database->name),
            '{dbEncoding}' => pg_escape_string($database->encoding),
            '{dbLcCollate}' => pg_escape_string($database->lc_collate),
            '{dbLcCtype}' => pg_escape_string($database->lc_ctype),
        ]
    );

    if (!empty($database->schema)) {
        $schemas = $database->schema;
        $schSqlArr = [];

        foreach ($schemas as $schema) {
            if (!empty($schema->name)) {
                if (!empty($schema->table)) {
                    $tables = $schema->table;
                    $tblSqlArr = [];
                    
                    foreach ($tables as $table) {
                        $tblSqlArr[] = strtr(
<<<EOD
create table "{schName}"."{tblName}" (
    
)
;
EOD
                            , [
                                '{schName}' => pg_escape_string($schema->name),
                                '{tblName}' => pg_escape_string($table->name),
                            ]
                        );
                    }
                }
                
                if (!empty($tblSqlArr)) {
                    array_walk($tblSqlArr, 'trim');
                    $tblSql = implode("\n\n", $tblSqlArr);
                }
                
                $schSqlArr[] = strtr(
<<<EOD
create schema "{schName}";
comment on schema "{schName}"
    is '{schComment}'
;
EOD
                    , [
                        '{schName}' => pg_escape_string($schema->name),
                        '{schComment}' => pg_escape_string($schema->comment),
                    ]
                );
            }
        }
        
        array_walk($schSqlArr, 'trim');
        $schSql = implode("\n\n", $schSqlArr);
    }
}

var_dump($tblSql);
