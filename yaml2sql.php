<?php

/**
 * yaml2sql.php
 * Author: Argem Gerald R. Flores <argemgrflores@gmail.com>
 * Creation date: 2014-03-01 10:00
 */

# require Spyc yaml loader/dumper
require_once 'Spyc.php';

# input yaml file
$inputFile = $argv[1];

if (!file_exists($inputFile)) {
    echo 'File not exists: ', $inputFile;
    return 1;
}

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
        
        foreach ($schemas as $schIdx => $schema) {
            if (!empty($schema->name)) {
                $schName = pg_escape_string($schema->name);
                
                $tblSqlArr = [];
                $tblSql = '';
                
                if (!empty($schema->table)) {
                    $tables = $schema->table;
                    
                    foreach ($tables as $tblIdx => $table) {
                        $tblName = pg_escape_string($table->name);
                        
                        if (!empty($table->column)) {
                            $columns = $table->column;
                            $colSqlArr = [];
                            $colSql = '';
                            
                            foreach ($columns as $colIdx => $column) {
                                if (!empty($column->name) and !empty($column->type)) {
                                    $colName = pg_escape_string($column->name);
                                    $colType = $column->type;
                                    $colAttributes = '';
                                    
                                    if (!empty($column->length)) {
                                        $colType = $colType . '(' . $column->length . ')';
                                    }
                                    
                                    if (!empty($column->not_null) or !empty($column->primary_key)) {
                                        $colAttributes .= ' not null ';
                                    }
                                    
                                    if (!empty($column->default_value)) {
                                        if (strpos($column->default_value, '()') > 0
                                            || in_array($column->default_value, ['true', 'false'])) {
                                            $colDefaultValue = $column->default_value;
                                        }
                                        else {
                                            $colDefaultValue = "'" . pg_escape_string($column->default_value) . "'";
                                        }
                                        
                                        $colAttributes .= ' default ' . $colDefaultValue . ' ';
                                    }
                                    
                                    // if (!empty($column->primary_key)) {
                                    //     $colAttributes .= ' primary key ';
                                    // }
                                    
                                    $colSqlArr[] = strtr(
<<<EOD
"{colName}" {colType} {colAttributes}
EOD
                                        , [
                                            '{colName}' => $colName,
                                            '{colType}' => $colType,
                                            '{colAttributes}' => $colAttributes,
                                        ]
                                    );
                                }
                            }
                            
                            if (!empty($colSqlArr)) {
                                $colSqlArr = array_map(function(&$val) {
                                    return str_replace('  ', ' ', trim($val));
                                }, $colSqlArr);
                                $colSql = implode(",\n    ", $colSqlArr);
                            }
                        }
                        
                        $tblSqlArr[$tblIdx] = strtr(
<<<EOD
create table "{schName}"."{tblName}" (
    {tblColumn}
) with (
    oids = false
);
EOD
                            , [
                                '{schName}' => $schName,
                                '{tblName}' => $tblName,
                                '{tblColumn}' => $colSql,
                            ]
                        );
                        
                        if (!empty($table->constraint)) {
                            $constraintArr = $table->constraint;
                            $cstSqlArr = [];
                            $cstSql = '';
                            
                            foreach ($constraintArr as $cstIdx => $constraint) {
                                if (!empty($constraint->name) and !empty($constraint->type) and !empty($constraint->column)) {
                                    $cstName = pg_escape_string($constraint->name);

                                    $cstAttributes = '';

                                    switch ($constraint->type) {
                                        case 'primary_key':
                                            $cstType = 'primary key';
                                            break;
                                        
                                        case 'foreign_key':
                                            $cstType = 'foreign key';
                                            
                                            if (!empty($constraint->attributes)) {
                                                $attributes = $constraint->attributes;
                                                
                                                if (!empty($attributes->foreign_table) and !empty($attributes->foreign_column)) {
                                                    if (strpos($attributes->foreign_table, '.')) {
                                                        list($foreignTable, $foreignColumn) = explode('.', $attributes->foreign_table);
                                                        $cstForeignTable = '"' . pg_escape_string($foreignTable) . '"."' . pg_escape_string($foreignColumn) . '"';
                                                    }
                                                    else {
                                                        $cstForeignTable = '"' . $attributes->foreign_table . '"';
                                                    }
                                                    
                                                    if (is_array($attributes->foreign_column)) {
                                                        $cstForeignColumn = '"' . implode('", "', $attributes->foreign_column) . '"';
                                                    }
                                                    else {
                                                        $cstForeignColumn = '"' . $attributes->foreign_column . '"';
                                                    }
                                                    
                                                    if (!empty($attributes->match_type)) {
                                                        $cstMatchType = 'match ' . $attributes->match_type;
                                                    }
                                                    else {
                                                        $cstMatchType = 'match simple';
                                                    }
                                                    
                                                    $cstAttributes = strtr(
<<<EOD
references {cstForeignTable} ({cstForeignColumn}) {cstMatchType}
EOD
                                                        , [
                                                            '{cstForeignTable}' => $cstForeignTable,
                                                            '{cstForeignColumn}' => $cstForeignColumn,
                                                            '{cstMatchType}' => $cstMatchType,
                                                        ]
                                                    );
                                                }
                                            }
                                    }
                                    
                                    if (is_array($constraint->column)) {
                                        $cstColumn = '"' . implode('", "', $constraint->column) . '"';
                                    }
                                    else {
                                        $cstColumn = '"' . $constraint->column . '"';
                                    }
                                    
                                    $cstSqlArr[] = strtr(
<<<EOD
alter table "{schName}"."{tblName}"
    add constraint "{cstName}"
    {cstType} ({cstColumn})
    {cstAttributes}
EOD
                                        , [
                                            '{schName}' => $schName,
                                            '{tblName}' => $tblName,
                                            '{cstName}' => $cstName,
                                            '{cstType}' => $cstType,
                                            '{cstColumn}' => $cstColumn,
                                            '{cstAttributes}' => $cstAttributes,
                                        ]
                                    );
                                }
                            }
                            
                            if (!empty($cstSqlArr)) {
                                $cstSqlArr = array_map(function(&$val) {
                                    return str_replace('  ', ' ', trim($val));
                                }, $cstSqlArr);
                                $cstSql = implode(";\n", $cstSqlArr) . ';';
                            }
                        }
                        
                        $tblSqlArr[$tblIdx] .= "\n\n" . $cstSql;
                    }
                }
                
                if (!empty($tblSqlArr)) {
                    $tblSqlArr = array_map('trim', $tblSqlArr);
                    $tblSql = implode("\n\n", $tblSqlArr);
                }
                
                $schSqlArr[$schIdx] = strtr(
<<<EOD
create schema "{schName}";
comment on schema "{schName}"
    is '{schComment}'
;
EOD
                    , [
                        '{schName}' => $schName,
                        '{schComment}' => pg_escape_string($schema->comment),
                    ]
                );
            }
        }
        
        $schSqlArr = array_map('trim', $schSqlArr);
        $schSql = implode("\n\n", $schSqlArr);
    }
}

echo $dbSql, "\n\n", $schSql, "\n\n", $tblSql, "\n";