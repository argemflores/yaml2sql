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

$cmtSqlArr = [];

if (!empty($input->database)) {
    $database = $input->database;
    $dbSql = '';
    
    $dbName = pg_escape_string($database->name);
    
    $dbSql = strtr(
<<<EOD
-- create database "{dbName}"
    -- encoding = '{dbEncoding}'
    -- lc_collate = '{dbLcCollate}'
    -- lc_ctype = '{dbLcCtype}';
EOD
        , [
            '{dbName}' => $dbName,
            '{dbEncoding}' => pg_escape_string(!empty($database->encoding) ? $database->encoding : 'UTF8'),
            '{dbLcCollate}' => pg_escape_string(!empty($database->lc_collate) ? $database->lc_collate : 'C'),
            '{dbLcCtype}' => pg_escape_string(!empty($database->lc_ctype) ? $database->lc_ctype : 'C'),
        ]
    );
    
    if (!empty($database->comment)) {
        $cmtSqlArr[] = strtr(
<<<EOD
comment on {objType} {objName}
    is '{cmtVal}';
EOD
            , [
                '{objType}' => 'database',
                '{objName}' => '"' . $dbName . '"',
                '{cmtVal}' => pg_escape_string($database->comment),
            ]
        );
    }

    if (!empty($database->schema)) {
        $schemas = $database->schema;
        $schSqlArr = [];
        $schSql = '';
        
        foreach ($schemas as $schIdx => $schema) {
            if (!empty($schema->name) and (empty($schema->options->skip) or $schema->options->skip != true)) {
                $schName = pg_escape_string($schema->name);
                
                if (!empty($schema->comment)) {
                    $cmtSqlArr[] = strtr(
<<<EOD
comment on {objType} {objName}
    is '{cmtVal}';
EOD
                        , [
                            '{objType}' => 'schema',
                            '{objName}' => '"' . $schName . '"',
                            '{cmtVal}' => pg_escape_string($schema->comment),
                        ]
                    );
                }
                
                $tblSqlArr = [];
                $tblSql = '';
                
                if (!empty($schema->table)) {
                    $tables = $schema->table;
                    
                    foreach ($tables as $tblIdx => $table) {
                        $tblName = pg_escape_string($table->name);
                        
                        if (!empty($table->comment)) {
                            $cmtSqlArr[] = strtr(
<<<EOD
comment on {objType} {objName}
    is '{cmtVal}';
EOD
                                , [
                                    '{objType}' => 'table',
                                    '{objName}' => '"' . $schName . '"."' . $tblName . '"',
                                    '{cmtVal}' => pg_escape_string($table->comment),
                                ]
                            );
                        }
                        
                        if (!empty($table->column)) {
                            $columns = $table->column;
                            
                            $colSqlArr = [];
                            $colSql = '';
                            
                            foreach ($columns as $colIdx => $column) {
                                if (!empty($column->name) and !empty($column->data_type)) {
                                    $colName = pg_escape_string($column->name);
                                    $colType = $column->data_type;
                                    $colAttributes = '';
                                    
                                    if (!empty($column->length)) {
                                        $colType = $colType . '(' . $column->length . ')';
                                    }
                                    
                                    if (!empty($column->not_null) or !empty($column->primary_key)) {
                                        $colAttributes .= ' not null ';
                                    }
                                    
                                    if (!empty($column->default_value)) {
                                        if (strpos($column->default_value, '()') > 0) {
                                            $colDefaultValue = $column->default_value;
                                        }
                                        else {
                                            $colDefaultValue = "'" . pg_escape_string($column->default_value) . "'";
                                        }
                                        
                                        $colAttributes .= ' default ' . $colDefaultValue . ' ';
                                    }
                                    
                                    if (!empty($column->comment)) {
                                        $cmtSqlArr[] = strtr(
<<<EOD
comment on {objType} {objName}
    is '{cmtVal}';
EOD
                                            , [
                                                '{objType}' => 'column',
                                                '{objName}' => '"' . $schName . '"."' . $tblName . '"."' . $colName . '"',
                                                '{cmtVal}' => pg_escape_string($column->comment),
                                            ]
                                        );
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
    oids = {tblWithOids}
);
EOD
                            , [
                                '{schName}' => $schName,
                                '{tblName}' => $tblName,
                                '{tblColumn}' => $colSql,
                                '{tblWithOids}' => !empty($table->with_oids) ? $table->with_oids : 'false',
                            ]
                        );
                        
                        $cstSql = '';
                        
                        if (!empty($table->constraint)) {
                            $constraintArr = $table->constraint;
                            $cstSqlArr = [];
                            
                            foreach ($constraintArr as $cstIdx => $constraint) {
                                if (!empty($constraint->type) and !empty($constraint->column)) {
                                    $cstAttributes = '';

                                    switch ($constraint->type) {
                                        case 'primary_key':
                                            $cstType = 'primary key';
                                            $cstSuffix = 'pkey';
                                            $objType = 'index';
                                            break;
                                        
                                        case 'foreign_key':
                                            $cstType = 'foreign key';
                                            $cstSuffix = 'fkey';
                                            $objType = 'constraint';
                                            
                                            if (!empty($constraint->other_attributes)) {
                                                $attributes = $constraint->other_attributes;
                                                
                                                if (!empty($attributes->foreign_table) and !empty($attributes->foreign_column)) {
                                                    if (strpos($attributes->foreign_table, '.') >= 0) {
                                                        list($foreignSchema, $foreignTable) = explode('.', $attributes->foreign_table);
                                                            
                                                        if (strpos($foreignSchema, '{schema}') >= 0) {
                                                            $foreignSchema = strtr($foreignSchema, [
                                                                '{schema}' => $schName,
                                                                '{table}' => $tblName,
                                                            ]);
                                                        }
                                                        
                                                        if (strpos($foreignTable, '{table}') >= 0) {
                                                            $foreignTable = strtr($foreignTable, [
                                                                '{schema}' => $schName,
                                                                '{table}' => $tblName,
                                                            ]);
                                                        }
                                                        
                                                        $cstForeignTable = '"' . pg_escape_string($foreignSchema) . '"."' . pg_escape_string($foreignTable) . '"';
                                                    }
                                                    else {
                                                        $cstForeignTable = '"' . pg_escape_string($attributes->foreign_table) . '"';
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
                                                    
                                                    if (!empty($attributes->on_update)) {
                                                        $cstOnUpdate = 'on update ' . $attributes->match_type;
                                                    }
                                                    else {
                                                        $cstOnUpdate = 'on update cascade';
                                                    }
                                                    
                                                    if (!empty($attributes->on_delete)) {
                                                        $cstOnDelete = 'on delete ' . $attributes->match_type;
                                                    }
                                                    else {
                                                        $cstOnDelete = 'on delete cascade';
                                                    }

                                                    
                                                    $cstAttributes = strtr(
<<<EOD
references {cstForeignTable} ({cstForeignColumn})
    {cstMatchType} {cstOnUpdate} {cstOnDelete}
EOD
                                                        , [
                                                            '{cstForeignTable}' => $cstForeignTable,
                                                            '{cstForeignColumn}' => $cstForeignColumn,
                                                            '{cstMatchType}' => $cstMatchType,
                                                            '{cstOnUpdate}' => $cstOnUpdate,
                                                            '{cstOnDelete}' => $cstOnDelete,
                                                        ]
                                                    );
                                                }
                                            }
                                    }
                                    
                                    if (is_array($constraint->column)) {
                                        $cstColumn = '"' . implode('", "', $constraint->column) . '"';
                                        $cstColumnName = implode('_', $constraint->column);
                                    }
                                    else {
                                        $cstColumn = '"' . $constraint->column . '"';
                                        $cstColumnName = $constraint->column;
                                    }
                                    
                                    if (empty($constraint->name)) {
                                        $cstName = pg_escape_string(strtr('{table}_{column}_{suffix}', [
                                            '{table}' => $tblName,
                                            '{column}' => $constraint->column,
                                            '{suffix}' => $cstSuffix,
                                        ]));
                                    }
                                    else {
                                        $cstName = pg_escape_string(strtr($constraint->name, [
                                            '{table}' => $tblName,
                                            '{column}' => $constraint->column,
                                        ]));
                                    }
                                    
                                    switch ($constraint->type) {
                                        case 'primary_key':
                                            $objName = '"' . $schName . '"."' . $cstName . '"';
                                            break;
                                        case 'foreign_key':
                                            $objName = '"' . $cstName . '" on "' . $schName . '"."' . $tblName . '"';
                                            break;
                                    }
                                    
                                    if (!empty($constraint->comment)) {
                                        $cmtSqlArr[] = strtr(
<<<EOD
comment on {objType} {objName}
    is '{cmtVal}';
EOD
                                            , [
                                                '{objType}' => $objType, # 'constraint',
                                                '{objName}' => $objName, # '"' . $schName . '"."' . $cstName . '"'
                                                // '{objTable}' => '"' . $schName . '"."' . $tblName . '"',
                                                '{cmtVal}' => pg_escape_string($constraint->comment),
                                            ]
                                        );
                                    }
                                    
                                    $cstSqlArr[] = strtr(
<<<EOD
alter table "{schName}"."{tblName}"
    add constraint "{cstName}"
    {cstType} ({cstColumn}) {cstAttributes}
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
                        
                        $idxSql = '';
                        if (!empty($table->index)) {
                            $indexArr = $table->index;
                            $idxSqlArr = [];
                            
                            foreach ($indexArr as $idxIdx => $index) {
                                if (!empty($index->column)) {
                                    if (is_array($index->column)) {
                                        $idxColumn = '"' . implode('", "', $index->column) . '"';
                                        $idxColumnName = implode('_', $index->column);
                                    }
                                    else {
                                        $idxColumn = '"' . $index->column . '"';
                                        $idxColumnName = $index->column;
                                    }
                                    
                                    if (empty($index->name)) {
                                        $idxName = strtr('{table}_{column}_idx', [
                                            '{table}' => $tblName,
                                            '{column}' => $idxColumnName,
                                        ]);
                                    }
                                    else {
                                        $idxName = strtr($index->name, [
                                            '{table}' => $tblName,
                                            '{column}' => $idxColumnName,
                                        ]);
                                    }
                                    
                                    if (!empty($index->comment)) {
                                        $cmtSqlArr[] = strtr(
<<<EOD
comment on {objType} {objName}
    is '{cmtVal}';
EOD
                                            , [
                                                '{objType}' => 'index',
                                                '{objName}' => '"' . $schName . '"."' . $idxName . '"',
                                                '{cmtVal}' => pg_escape_string($index->comment),
                                            ]
                                        );
                                    }
                                    
                                    $idxSqlArr[] = strtr(
<<<EOD
create {idxUnique} index {idxConcurrent} "{idxName}"
    on "{schName}"."{tblName}"
    using {idxUsing} ({idxColumn})
EOD
                                        , [
                                            '{idxUnique}' => !empty($index->unique) ? 'unique' : '',
                                            '{idxConcurrent}' => !empty($idxConcurrent) ? 'concurrently' : '',
                                            '{idxName}' => $idxName,
                                            '{schName}' => $schName,
                                            '{tblName}' => $tblName,
                                            '{idxUsing}' => !empty($index->using) ? $index->using : 'btree',
                                            '{idxColumn}' => $idxColumn,
                                        ]
                                    );
                                }
                            }
                            
                            if (!empty($idxSqlArr)) {
                                $idxSqlArr = array_map(function(&$val) {
                                    return str_replace('  ', ' ', trim($val));
                                }, $idxSqlArr);
                                $idxSql = implode(";\n", $idxSqlArr) . ';';
                            }
                        }
                        
                        $tblSqlArr[$tblIdx] .= "\n\n" . $cstSql . "\n\n" . $idxSql;
                    }
                }
                
                if (!empty($tblSqlArr)) {
                    $tblSqlArr = array_map('trim', $tblSqlArr);
                    $tblSql = implode("\n\n-- ----------------\n\n", $tblSqlArr);
                }
                
                $schSqlArr[$schIdx] = strtr(
<<<EOD
create schema "{schName}";

{tblSql}
EOD
                    , [
                        '{schName}' => $schName,
                        '{tblSql}' => $tblSql,
                    ]
                );
            }
        }
        
        $schSqlArr = array_map('trim', $schSqlArr);
        $schSql = implode("\n\n-- --------------------------------\n\n", $schSqlArr);
    }
}

if (!empty($cmtSqlArr)) {
    $cmtSqlArr = array_map(function(&$val) {
        return str_replace('  ', ' ', trim($val));
    }, $cmtSqlArr);
    $cmtSql = implode("\n\n", $cmtSqlArr);
}

if (!empty($database->options)) {
    $dbOpts = $database->options;
    
    if (isset($dbOpts->drop_schema) and $dbOpts->drop_schema == true) {
        $schemas = $database->schema;
        $schDropSql = '';
        
        foreach ($schemas as $schIdx => $schema) {
            if (!empty($schema->name)) {
                $schDropSql .= strtr(
<<<EOD
drop schema if exists "{schName}" cascade;\n\n
EOD
                    , [
                        '{schName}' => pg_escape_string($schema->name),
                    ]
                );
            }
        }
        
        if (isset($dbOpts->drop_database) and $dbOpts->drop_database == true) {
            echo strtr(
<<<EOD
drop database "{dbName}";
EOD
                , [
                    '{dbName}' => pg_escape_string($dbName),
                ]
            );
        }
        
        echo $schDropSql, "-- --------------------------------\n\n";
    }
}

echo $dbSql, "\n\n-- --------------------------------\n\n",
    $schSql, "\n\n";
// echo $cmtSql, "\n\n";

// var_dump(json_encode(Spyc::YAMLLoad($inputFile)));
