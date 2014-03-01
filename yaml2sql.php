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
    $dbSql = '';

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
        $schSql = '';

        foreach ($schemas as $schema) {
            if (!empty($schema->name)) {
                $tblSqlArr = [];
                $tblSql = '';
                
                if (!empty($schema->table)) {
                    $tables = $schema->table;
                    
                    foreach ($tables as $table) {
                        if (!empty($table->column)) {
                            $columns = $table->column;
                            $colSqlArr = [];
                            $colSql = '';
                            
                            foreach ($columns as $column) {
                                if (!empty($column->name) and !empty($column->type)) {
                                    $colName = pg_escape_string($column->name);
                                    $colType = $column->type;
                                    $colLength = '';
                                    $colNotNull = '';
                                    $colDefaultValue = '';
                                    $colPrimaryKey = '';
                                    $colIndexed = '';
                                    
                                    if (!empty($column->length)) {
                                        $colType = $colType . '(' . $column->length . ')';
                                    }
                                    
                                    if (!empty($column->not_null)) {
                                        $colNotNull = 'not null';
                                    }
                                    
                                    if (!empty($column->default_value)) {
                                        if (strpos($column->default_value, '()') > 0
                                            || in_array($column->default_value, ['true', 'false'])) {
                                            $colDefaultValue = $column->default_value;
                                        }
                                        else {
                                            $colDefaultValue = "'" . pg_escape_string($column->default_value) . "'";
                                        }
                                        
                                        $colDefaultValue = 'default ' . $colDefaultValue;
                                    }
                                    
                                    
                                    
                                    $colSqlArr[] = strtr(
<<<EOD
"{colName}" {colType} {colNotNull} {colDefaultValue}
EOD
                                        , [
                                            '{colName}' => $colName,
                                            '{colType}' => $colType,
                                            '{colNotNull}' => $colNotNull,
                                            '{colDefaultValue}' => $colDefaultValue,
                                        ]
                                    );
                                }
                            }
                            
                            if (!empty($colSqlArr)) {
                                $colSqlArr = array_map('trim', $colSqlArr);
                                $colSql = implode(",\n    ", $colSqlArr);
                            }
                            
                            // var_dump($colSql);
                        }
                        
                        $tblSqlArr[] = strtr(
<<<EOD
create table "{schName}"."{tblName}" (
    {tblColumn}
)
;
EOD
                            , [
                                '{schName}' => pg_escape_string($schema->name),
                                '{tblName}' => pg_escape_string($table->name),
                                '{tblColumn}' => $colSql,
                            ]
                        );
                    }
                }
                
                if (!empty($tblSqlArr)) {
                    $tblSqlArr = array_map('trim', $tblSqlArr);
                    $tblSql = implode("\n\n", $tblSqlArr);
                }
                
                var_dump($tblSql);
                
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
        
        $schSqlArr = array_map('trim', $schSqlArr);
        $schSql = implode("\n\n", $schSqlArr);
    }
}
