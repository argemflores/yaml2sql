<?php

/**
 * yaml2sql.php
 * Author: Argem Gerald R. Flores <argemgrflores@gmail.com>
 * Creation date: 2014-03-01 10:00
 */

if (!isset($argv[1]) or !file_exists($argv[1])) {
    echo 'File ain\'t existing: ', $argv[1];
    return 1;
}

# input yaml file
$inputFile = $argv[1];

# require Spyc yaml loader/dumper
require_once 'Spyc.php';

$array = Spyc::YAMLLoad($inputFile);

# load input file and convert yaml contents to array, then to object
$object = json_decode(json_encode($array));

if (isset($argv[2])) {
    switch (strtolower($argv[2])) {
        case 'array':
            var_dump($array);
            return;
        case 'object':
            var_dump($object);
            return;
    }
}

# global variables
$sql = '';
$cmtSqlArr = [];
$dictArr = [
    'database' => [
        [
            'database_name',
            'encoding',
            'lc_collate',
            'lc_ctype',
            'comment',
        ]
    ],
    'schema' => [
        [
            'database_name',
            'schema_name',
            'comment',
        ]
    ],
    'table' => [
        [
            'database_name',
            'schema_name',
            'table_name',
            'comment',
        ]
    ],
    'column' => [
        [
            'database_name',
            'schema_name',
            'table_name',
            'column_name',
            'data_type',
            'length',
            'not_null',
            'default_value',
            'comment',
            'order_number',
        ]
    ],
    'constraint' => [
        [
            'database_name',
            'schema_name',
            'table_name',
            'constraint_name',
            'type',
            'column',
            'foreign_table',
            'foreign_column',
            'on_update',
            'on_delete',
            'match_type',
            'no_inherit',
            'expression',
            'command',
            'comment',
        ]
    ],
    'index' => [
        [
            'database_name',
            'schema_name',
            'table_name',
            'index_name',
            'column',
            'using',
            'unique',
            'concurrent',
            'comment',
        ]
    ],
    'sequence' => [
        [
            'database_name',
            'schema_name',
            'table_name',
            'sequence_name',
            'start_value',
            'increment',
            'minimum_value',
            'maximum_value',
            'cache',
            'cycle',
            'comment',
        ]
    ],
];

# get current directory
$curDir = dirname(__FILE__);

# non-empty database object
if (!empty($object->database)) {
    $database = $object->database;
    $dbSql = '';
    
    # escape database name in postgres format
    $dbName = pg_escape_string($database->name);
    $dbEncoding = pg_escape_string(!empty($database->encoding) ? $database->encoding : 'UTF8');
    $dbLcCollate = pg_escape_string(!empty($database->lc_collate) ? $database->lc_collate : 'C');
    $dbLcCtype = pg_escape_string(!empty($database->lc_ctype) ? $database->lc_ctype : 'C');
    
    $dbValArr = [
        '{dbName}' => $dbName,
        '{dbEncoding}' => $dbEncoding,
        '{dbLcCollate}' => $dbLcCollate,
        '{dbLcCtype}' => $dbLcCtype,
    ];
    
    # generate create database commands
    $dbSql = strtr(
<<<EOD
create database "{dbName}"
    encoding = '{dbEncoding}'
    lc_collate = '{dbLcCollate}'
    lc_ctype = '{dbLcCtype}';
EOD
        , $dbValArr
    );
    
    # add comment to database
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
    
    $dictArr['database'][] = array_merge([], $dbValArr, [empty($database->comment) ? null : $database->comment]);
    
    # database has one or more shemas
    if (!empty($database->schema)) {
        $schemas = $database->schema;
        $schSqlArr = [];
        $schSql = '';
        
        # process schema one by one
        foreach ($schemas as $schIdx => $schema) {
            # schema name is not empty and not to be skipped (defined by options skip property)
            if (!empty($schema->name) and (empty($schema->options->skip) or $schema->options->skip != true)) {
                $schName = pg_escape_string($schema->name);
                
                # add comment to schema
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
                
                # array of sqls for creating tables
                $tblSqlArr = [];
                $tblSql = '';
                
                # schema has one or more tables
                if (!empty($schema->table)) {
                    $tables = $schema->table;
                    
                    # process tables one by one
                    foreach ($tables as $tblIdx => $table) {
                        $tblName = pg_escape_string($table->name);
                        
                        # add comment to table
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
                        
                        # table has one or more columns
                        if (!empty($table->column)) {
                            $columns = $table->column;
                            
                            $colSqlArr = [];
                            $colSql = '';
                            
                            # process columns one by one
                            foreach ($columns as $colIdx => $column) {
                                # column has name and data_type properties
                                if (!empty($column->name) and !empty($column->data_type)) {
                                    $colName = pg_escape_string($column->name);
                                    $colType = $column->data_type;
                                    $colAttributes = '';
                                    
                                    # maximum length depending on data type
                                    if (!empty($column->length)) {
                                        $colType = $colType . '(' . $column->length . ')';
                                    }
                                    
                                    # can not be null
                                    if (!empty($column->not_null) or !empty($column->primary_key)) {
                                        $colAttributes .= ' not null ';
                                    }
                                    
                                    # has default value
                                    if (isset($column->default_value)) {
                                        # boolean
                                        if (is_bool($column->default_value)) {
                                            $colDefaultValue = $column->default_value ? 'true' : 'false';
                                        }
                                        # function/method
                                        elseif (strpos($column->default_value, '()') > 0) {
                                            $colDefaultValue = $column->default_value;
                                        }
                                        # any other default values
                                        else {
                                            $colDefaultValue = "'" . pg_escape_string($column->default_value) . "'";
                                        }
                                        
                                        # set default value command
                                        $colAttributes .= ' default ' . $colDefaultValue . ' ';
                                    }
                                    
                                    # add comment to column
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
                                    
                                    // if (empty($column->type)) {
                                    //     echo $schName, '.', $tblName, '.', $column->name, "\n";
                                    // }
                                    
                                    // if (!empty($column->type))
                                    // {
                                    //     // if (!empty($varArr[$column->type][$column->name]))
                                    //     //     $varArr[$column->type][$column->name] = $varArr[$column->type][$column->name] + 1;
                                    //     // else
                                    //     //     $varArr[$column->type][$column->name] = 1;
                                    //     $varArr[] = [
                                    //         str_replace(' ', '_', $column->name), // abbrev
                                    //         str_replace(' ', '_', $column->name), // label
                                    //         $column->name, // name
                                    //         isset($column->comment) ? $column->comment : null, // description
                                    //         $column->data_type, // data_type
                                    //         isset($column->not_null) ? $column->not_null : null, // not_null
                                    //         $column->type, // type
                                    //         isset($column->status) ? $column->status : null, // status
                                    //         ucfirst($column->name), // display_name
                                    //     ];
                                    // }
                                    
                                    # generate command to adding the column to the table
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
                                    
                                    $dictArr['column'][] = array_merge([$dbName, $schName, $tblName], [
                                        $colName,
                                        $colType,
                                        isset($column->length) ? $column->length : null,
                                        isset($column->not_null) ? $column->not_null : null,
                                        isset($column->default_value) ? $column->default_value : null,
                                        isset($column->comment) ? $column->comment : null,
                                        $colIdx + 1,
                                    ]);
                                    
                                    if ($colType == 'serial') {
                                        $seqName = $tblName . '_' . $colName . '_seq';
                                        $dictArr['sequence'][$seqName] = array_merge([$dbName, $schName], [
                                            $seqName,
                                            1,
                                            1,
                                            '2147483647',
                                            1,
                                            1,
                                            false,
                                            isset($sequence->comment) ? $sequence->comment : null,
                                        ]);
                                    }
                                }
                            }
                            
                            # merge all columns to one command list
                            if (!empty($colSqlArr)) {
                                $colSqlArr = array_map(function(&$val) {
                                    return str_replace('  ', ' ', trim($val));
                                }, $colSqlArr);
                                $colSql = implode(",\n    ", $colSqlArr);
                            }
                        }
                        
                        # merge commands in creating table and adding its columns
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
                        
                        $dictArr['table'][] = array_merge([$dbName, $schName], [
                            $tblName,
                            isset($table->comment) ? $table->comment : null,
                        ]);
                        
                        # table has one or more constraints
                        $cstSql = '';
                        if (!empty($table->constraint)) {
                            $constraintArr = $table->constraint;
                            $cstSqlArr = [];
                            
                            # process constraints one by one
                            foreach ($constraintArr as $cstIdx => $constraint) {
                                # type and column/s associated with constraint is defined
                                if (!empty($constraint->type) and !empty($constraint->column)) {
                                    $cstAttributes = '';
                                    
                                    # decide with command to generate on constraint based on its type
                                    switch (strtolower($constraint->type)) {
                                        # primary key constraint
                                        # uniquely identifies a record in a table
                                        # used in references to other tables
                                        case 'primary_key':
                                            $cstType = 'primary key';
                                            $cstSuffix = 'pkey';
                                            $objType = 'index';
                                            break;
                                        
                                        # unique constraint
                                        # no two records of the same value can be added to a column
                                        case 'unique_key':
                                            $cstType = 'unique';
                                            $cstSuffix = 'ukey';
                                            $objType = 'constraint';
                                            break;
                                        
                                        # foreign key constraint
                                        # describes if column/s of table has reference to column/s of another table
                                        case 'foreign_key':
                                            $cstType = 'foreign key';
                                            $cstSuffix = 'fkey';
                                            $objType = 'constraint';
                                            
                                            # other attributes needed on a constraint type (foreign key)
                                            if (!empty($constraint->other_attributes)) {
                                                $attributes = $constraint->other_attributes;
                                                
                                                # foreign table and foreign column/s must be defined
                                                # if the constraint type is a foreign key
                                                if (!empty($attributes->foreign_table) and !empty($attributes->foreign_column)) {
                                                    # foreign table is schema-qualified
                                                    if (strpos($attributes->foreign_table, '.') >= 0) {
                                                        list($foreignSchema, $foreignTable) = explode('.', $attributes->foreign_table);
                                                        
                                                        # format schema name
                                                        if (strpos($foreignSchema, '{schema}') >= 0) {
                                                            $foreignSchema = strtr($foreignSchema, [
                                                                '{schema}' => $schName,
                                                                '{table}' => $tblName,
                                                            ]);
                                                        }
                                                        
                                                        # format table name
                                                        if (strpos($foreignTable, '{table}') >= 0) {
                                                            $foreignTable = strtr($foreignTable, [
                                                                '{schema}' => $schName,
                                                                '{table}' => $tblName,
                                                            ]);
                                                        }
                                                        
                                                        # join shema and table names
                                                        $cstForeignTable = '"' . pg_escape_string($foreignSchema) . '"."' . pg_escape_string($foreignTable) . '"';
                                                    }
                                                    else {
                                                        # only the foreign table is defined
                                                        # meaning the foreign table is within the same schema
                                                        $cstForeignTable = '"' . pg_escape_string($attributes->foreign_table) . '"';
                                                    }
                                                    
                                                    # possibly more than one foreign columns (defined as array)
                                                    if (is_array($attributes->foreign_column)) {
                                                        # join column names
                                                        $cstForeignColumn = '"' . implode('", "', $attributes->foreign_column) . '"';
                                                    }
                                                    else {
                                                        # only one column
                                                        $cstForeignColumn = '"' . $attributes->foreign_column . '"';
                                                    }
                                                    
                                                    # match type to use in reference
                                                    if (!empty($attributes->match_type)) {
                                                        $cstMatchType = 'match ' . $attributes->match_type;
                                                    }
                                                    else {
                                                        # default match type is simple
                                                        $cstMatchType = 'match simple';
                                                    }
                                                    
                                                    # what to do on update event
                                                    if (!empty($attributes->on_update)) {
                                                        $cstOnUpdate = 'on update ' . $attributes->match_type;
                                                    }
                                                    else {
                                                        # default behavior is cascade
                                                        $cstOnUpdate = 'on update cascade';
                                                    }
                                                    
                                                    # what to do on delete event
                                                    if (!empty($attributes->on_delete)) {
                                                        $cstOnDelete = 'on delete ' . $attributes->match_type;
                                                    }
                                                    else {
                                                        # default behavior is cascade
                                                        $cstOnDelete = 'on delete cascade';
                                                    }

                                                    # generate command to add foreign key constraint to table definition
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
                                    
                                    # column/s where the constraint is applied
                                    if (is_array($constraint->column)) {
                                        # column constraints
                                        $cstColumn = '"' . implode('", "', $constraint->column) . '"';
                                        # constraint column name
                                        $cstColumnName = implode('_', $constraint->column);
                                    }
                                    else {
                                        # one column only
                                        $cstColumn = '"' . $constraint->column . '"';
                                        $cstColumnName = $constraint->column;
                                    }
                                    
                                    # name of constraint
                                    if (empty($constraint->name)) {
                                        # default constraint name
                                        $cstName = pg_escape_string(strtr('{table}_{column}_{suffix}', [
                                            '{table}' => $tblName,
                                            '{column}' => $cstColumnName,
                                            '{suffix}' => $cstSuffix,
                                        ]));
                                    }
                                    else {
                                        # custom constraint name
                                        $cstName = pg_escape_string(strtr($constraint->name, [
                                            '{table}' => $tblName,
                                            '{column}' => $cstColumnName,
                                        ]));
                                    }
                                    
                                    # add comment to constraint based on its type
                                    switch ($constraint->type) {
                                        case 'primary_key':
                                            $objName = '"' . $schName . '"."' . $cstName . '"';
                                            break;
                                        case 'foreign_key':
                                            $objName = '"' . $cstName . '" on "' . $schName . '"."' . $tblName . '"';
                                            break;
                                    }
                                    
                                    # add comment to constraint
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
                                    
                                    # add command to alter tale to add constraint
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
                                    
                                    $dictArr['constraint'][] = array_merge([$dbName, $schName, $tblName], [
                                        $cstName,
                                        $constraint->type,
                                        $cstColumn,
                                        isset($cstForeignTable) ? $cstForeignTable : null,
                                        isset($cstForeignColumn) ? $cstForeignColumn : null,
                                        isset($constraint->other_attributes->on_update) ? $constraint->other_attributes->on_update : ($constraint->type == 'foreign_key' ? 'cascade' : null),
                                        isset($constraint->other_attributes->on_delete) ? $constraint->other_attributes->on_delete : ($constraint->type == 'foreign_key' ? 'cascade' : null),
                                        isset($constraint->other_attributes->match_type) ? $constraint->other_attributes->match_type : ($constraint->type == 'foreign_key' ? 'simple' : null),
                                        isset($constraint->other_attributes->no_inherit) ? $constraint->other_attributes->no_inherit : false,
                                        isset($constraint->other_attributes->expression) ? $constraint->other_attributes->expression : null,
                                        isset($constraint->command) ? $constraint->command : null,
                                        isset($constraint->comment) ? $constraint->comment : null,
                                    ]);
                                }
                            }
                            
                            # merge all alter table constraints
                            if (!empty($cstSqlArr)) {
                                $cstSqlArr = array_map(function(&$val) {
                                    return str_replace('  ', ' ', trim($val));
                                }, $cstSqlArr);
                                $cstSql = implode(";\n", $cstSqlArr) . ';';
                            }
                        }
                        
                        # table has one or more indexes
                        $idxSql = '';
                        if (!empty($table->index)) {
                            $indexArr = $table->index;
                            $idxSqlArr = [];
                            
                            # process indexes one by one
                            foreach ($indexArr as $idxIdx => $index) {
                                # column/s to be indexed is defined
                                if (!empty($index->column)) {
                                    if (is_array($index->column)) {
                                        $idxColumn = '"' . implode('", "', $index->column) . '"';
                                        $idxColumnName = implode('_', $index->column);
                                    }
                                    else {
                                        # only one column
                                        $idxColumn = '"' . $index->column . '"';
                                        $idxColumnName = $index->column;
                                    }
                                    
                                    # name of index
                                    if (empty($index->name)) {
                                        # default index name
                                        $idxName = strtr('{table}_{column}_idx', [
                                            '{table}' => $tblName,
                                            '{column}' => $idxColumnName,
                                        ]);
                                    }
                                    else {
                                        # custom index name
                                        $idxName = strtr($index->name, [
                                            '{table}' => $tblName,
                                            '{column}' => $idxColumnName,
                                        ]);
                                    }
                                    
                                    # add comment to index
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
                                    
                                    # add command to list of index sqls
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
                                    
                                    $dictArr['index'][] = array_merge([$dbName, $schName, $tblName], [
                                        $idxName,
                                        is_array($index->column) ? implode(',', $index->column) : $index->column,
                                        isset($index->using) ? $index->using : 'btree',
                                        isset($index->unique) ? $index->unique : null,
                                        isset($index->concurrent) ? $index->concurrent : null,
                                        isset($index->comment) ? $index->comment : null,
                                    ]);
                                }
                            }
                            
                            # merge all commands to create indexes to table
                            if (!empty($idxSqlArr)) {
                                $idxSqlArr = array_map(function(&$val) {
                                    return str_replace('  ', ' ', trim($val));
                                }, $idxSqlArr);
                                $idxSql = implode(";\n", $idxSqlArr) . ';';
                            }
                        }
                        
                        # table is to be populated with data using copy command with csv file as input
                        $copySql = '';
                        if (!empty($table->copy) and !empty($table->copy->from)) {
                            $copy = $table->copy;
                            
                            # column/s where to insert the data from csv files 
                            $copyCol = '';
                            if (!empty($copy->column)) {
                                $copyCol = "(\n    \"" . implode("\",\n    \"", $copy->column) . "\"\n)";
                            }
                            
                            $copyFrom = '';
                            $copyFromFlag = true;
                            $copyValues = '';
                            # copy data from standard input
                            if (!empty($copy->option->stdin)) {
                                $copyFrom = 'stdin';
                                
                                # csv file path
                                $copyFilePath = strtr($copy->from, [
                                    '{curdir}' => pg_escape_string($curDir),
                                    '{schema}' => $schName,
                                    '{table}' => $tblName,
                                ]);
                                
                                # echo contents to standaart input
                                if (file_exists($copyFilePath)) {
                                    $copyValues = file_get_contents($copyFilePath, true);
                                }
                                else {
                                    # file does not exist
                                    $copyFromFlag = false;
                                }
                            }
                            else {
                                # copy csv file
                                $copyFrom = strtr($copy->from, [
                                    '{curdir}' => pg_escape_string($curDir),
                                    '{schema}' => $schName,
                                    '{table}' => $tblName,
                                ]);
                                
                                # file does not exists
                                if (!file_exists($copyFrom)) {
                                    $copyFromFlag = false;
                                }
                            }
                            
                            # file exists
                            if ($copyFromFlag) {
                                # format of copying
                                $copyFormat = '';
                                if (!empty($copy->option->format)) {
                                    $copyFormat = $copy->option->format;
                                }
                                
                                # csv file contains headers
                                $copyHeader = '';
                                if (!empty($copy->option->header)) {
                                    $copyHeader = $copy->option->header;
                                }
                                
                                # option list for copying
                                # may contain delimiter, qoute char, null value, etc.
                                $copyOptionList = '';
                                if (!empty($copy->option->list)) {
                                    foreach ($copy->option->list as $key => $val) {
                                        $copyOptionList .= $key . ' ' . $val . "\n    ";
                                    }
                                }
                                
                                # generate copy command for table
                                $copySql = strtr(
<<<EOD
copy "{schName}"."{tblName}" {copyCol}
from {copyFrom}
    {copyFormat}
    {copyHeader}
    {copyOptionList}
;
{copyValues}
\.

EOD
                                    , [
                                        '{schName}' => $schName,
                                        '{tblName}' => $tblName,
                                        '{copyCol}' => trim($copyCol),
                                        '{copyFrom}' => trim($copyFrom),
                                        '{copyFormat}' => trim($copyFormat),
                                        '{copyHeader}' => trim($copyHeader),
                                        '{copyOptionList}' => trim($copyOptionList),
                                        '{copyValues}' => trim($copyValues),
                                    ]
                                );
                            }
                        }
                        
                        # table has one or more sequences
                        $seqSql = '';
                        $seqSqlPost = '';
                        if (!empty($table->sequence)) {
                            $sequence = $table->sequence;
                            
                            $seqColName = 'id';
                            if (!empty($sequence->column_name)) {
                                $seqColName = $sequence->column_name;
                            }
                            # name of sequnce
                            if (!empty($sequence->name)) {
                                # custom sequence name
                                $seqName = $sequence->name;
                            }
                            else {
                                # default sequence name
                                $seqName = pg_escape_string($tblName . '_' . $seqColName . '_seq');
                            }
                            
                            # starting number of sequence
                            $seqStartWith = 1;
                            if (!empty($sequence->start_with)) {
                                $seqStartWith = $sequence->start_with;
                            }
                            
                            # minimum value
                            $seqMinValue = 1;
                            if (!empty($sequence->minvalue)) {
                                $seqMinValue = $sequence->minvalue;
                            }
                            
                            # maximum value
                            $seqMaxValue = '9223372036854775807';
                            if (!empty($sequence->maxvalue)) {
                                $seqMaxValue = $sequence->maxvalue;
                            }
                            
                            # incrementing value
                            $seqIncrementBy = 1;
                            if (!empty($sequence->increment_by)) {
                                $seqIncrementBy = $sequence->increment_by;
                            }
                            
                            # incrementing value
                            $seqCache = 1;
                            if (!empty($sequence->cache)) {
                                $seqIncrementBy = $sequence->cache;
                            }
                            
                            # incrementing value
                            $seqNoCycle = 'no cycle';
                            if (!empty($sequence->cycle)) {
                                $seqNoCycle = 'cycle';
                            }
                            
                            # generate alter sequence command to table
                            $seqSql .= strtr(
<<<EOD
alter sequence "{schName}"."{seqName}"
  restart {seqStartWith};

alter sequence "{schName}"."{seqName}"
  start with {seqStartWith}
  minvalue {seqMinValue}
  maxvalue {seqMaxValue}
  increment by {seqIncrementBy}
  cache {seqCache}
  {seqNoCycle};
EOD
                                , [
                                    '{schName}' => $schName,
                                    '{seqName}' => $seqName,
                                    '{seqStartWith}' => $seqStartWith,
                                    '{seqMinValue}' => $seqMinValue,
                                    '{seqMaxValue}' => $seqMaxValue,
                                    '{seqIncrementBy}' => $seqIncrementBy,
                                    '{seqCache}' => $seqCache,
                                    '{seqNoCycle}' => $seqNoCycle,
                                ]
                            );
                            
                            $seqStartWith = 1;
                            if (!empty($sequence->restart)) {
                                $seqSqlPost = $seqSql;
                                $seqSql = '';
                            }
                            
                            $seqName = $tblName . '_' . $seqColName . '_seq';
                            $dictArr['sequence'][$seqName] = array_merge([$dbName, $schName], [
                                $seqName,
                                $seqStartWith,
                                $seqIncrementBy,
                                $seqMinValue,
                                $seqMaxValue,
                                $seqCache,
                                $seqNoCycle,
                                isset($seq->comment) ? $seq->comment : null,
                            ]);
                        }
                        
                        # other sql commans to be executed after the table has been created
                        $tblpostSql = '';
                        if (!empty($table->options)) {
                            $tblOpts = $table->options;
                            
                            # append sql statements
                            if (!empty($tblOpts->append_sql)) {
                                // $tblpostSql .= "execute '" . pg_escape_string($tblOpts->append_sql) . "';";
                                $tblpostSql .= $tblOpts->append_sql;
                            }
                        }
                        
                        # add table sql commands to list
                        $tblSqlArr[$tblIdx] .= "\n\n" . $cstSql . "\n\n" . $idxSql . "\n\n" . $seqSql . "\n\n" . $copySql . "\n\n" . $seqSqlPost . "\n\n" . $tblpostSql;
                    }
                }
                
                # merge all commadnsd to create table
                if (!empty($tblSqlArr)) {
                    $tblSqlArr = array_map('trim', $tblSqlArr);
                    $tblSql = implode("\n\n-- ----------------\n\n", $tblSqlArr);
                }
                
                # schema has one or more views
                $viewSqlArr = [];
                $viewSql = '';
                if (!empty($schema->view)) {
                    $views = $schema->view;
                    
                    # process views one by one
                    foreach ($views as $viewIdx => $view) {
                        # name and query body of view are defined
                        if (!empty($view->name) and !empty($view->query)) {
                            $viewName = '"' . $schName . '"."' . pg_escape_string($view->name) . '"';
                            
                            $viewSqlArr[$viewIdx] = strtr(
<<<EOD
create view {viewName} as
{viewQuery}
EOD
                                , [
                                    '{viewName}' => $viewName,
                                    '{viewQuery}' => $view->query,
                                ]
                            );
                            
                            # add comment to view
                            if (!empty($view->comment)) {
                                $cmtSqlArr[] = strtr(
<<<EOD
comment on {objType} {objName}
    is '{cmtVal}';
EOD
                                    , [
                                        '{objType}' => 'view',
                                        '{objName}' => $viewName,
                                        '{cmtVal}' => pg_escape_string($view->comment),
                                    ]
                                );
                            }
                        }
                    }
                }
                
                # one or more views are to be created for the schema
                if (!empty($viewSqlArr)) {
                    $viewSqlArr = array_map('trim', $viewSqlArr);
                    $viewSql = implode("\n\n-- ----------------\n\n", $viewSqlArr);
                }
                
                $schValArr = [
                    '{schName}' => $schName,
                    '{tblSql}' => $tblSql,
                    '{viewSql}' => $viewSql,
                ];
                
                # create schema, with its tables, and views, if any
                $schSqlArr[$schIdx] = strtr(
<<<EOD
create schema "{schName}";

{tblSql}

{viewSql}
EOD
                    , $schValArr
                );
                
                $dictArr['schema'][] = array_merge([$dbName], [
                    $schName
                ], [empty($schema->comment) ? null : $schema->comment]);
            }
        }
        
        $schSqlArr = array_map('trim', $schSqlArr);
        $schSql = implode("\n\n-- --------------------------------\n\n", $schSqlArr);
    }
}

# merge all comment commands
if (!empty($cmtSqlArr)) {
    $cmtSqlArr = array_map(function(&$val) {
        return str_replace('  ', ' ', trim($val));
    }, $cmtSqlArr);
    $cmtSql = implode("\n\n", $cmtSqlArr);
}

# print sql commands
if (empty($database->options->dump)) {
    # database has custom properties or options
    $preSql = '';
    $postSql = '';
    if (!empty($database->options)) {
        $dbOpts = $database->options;
        
        # terminate all connections to database before running sql commands
        if (isset($dbOpts->terminate_connections) and $dbOpts->terminate_connections == true) {
            echo "select pg_terminate_backend(pid) from pg_stat_activity where datname='{$dbName}' and pid <> pg_backend_pid();",
                "\n\n-- --------------------------------\n\n";
        }
        
        # drop database if exists before running commands
        if (isset($dbOpts->drop_database) and $dbOpts->drop_database == true) {
            echo strtr(
<<<EOD
drop database if exists "{dbName}";\n\n
EOD
                , [
                    '{dbName}' => pg_escape_string($dbName),
                ]
            ), $dbSql, "\n\n-- --------------------------------\n\n";
        }
        # drop schema/s if exists
        elseif (isset($dbOpts->drop_schema) and $dbOpts->drop_schema == true) {
            $schemas = $database->schema;
            $schDropSql = '';
            
            # process drop commands for schemas one by one
            foreach ($schemas as $schIdx => $schema) {
                # overrid drop command for a schema if schema is set to skip drop
                if (!empty($schema->name) and (!isset($schema->options->skip_drop) or $schema->options->skip_drop != true)) {
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
            
            echo $schDropSql, "-- --------------------------------\n\n";
        }
        
        # post-sql commands are to be run for the database
        if (!empty($dbOpts->append_sql) and empty($database->options->skip_append_sql)) {
            # add append sqls to end of commands
            $postSql .= strtr($dbOpts->append_sql, [
                '{curdir}' => pg_escape_string($curDir),
            ]);
        }
    }

    echo $schSql, "\n\n";
    echo $cmtSql, "\n\n";
    echo "\n\n-- --------------------------------\n\n",
        $postSql, "\n\n";
}

foreach ($dictArr as $objType => $objArr) {
    $filePath = $curDir . "\\dictionary.{$objType}.csv";
    $fp = fopen($filePath, 'w');

    foreach ($objArr as $obj) {
        $obj2 = [];
        foreach ($obj as $o) {
            # $obj2[] = pg_escape_string(str_replace(array("\r\n","\r","\n",'  '), "\\n", $o));
            $obj2[] = pg_escape_string($o);
        }
        
        fputcsv($fp, $obj2, ';', '"');
    }

    fclose($fp);
}
