<?php

return [
    'class' => 'yii\db\Connection',
    'dsn' => getenv("DOCKER_RUNNING") ? 'pgsql:host=database;dbname=gigadb;port=5432' : 'pgsql:host=localhost;dbname=gigadb;port=54321',
    'username' => 'gigadb',
    'password' => 'vagrant',
    'charset' => 'utf8',

    // Schema cache options (for production environment)
    //'enableSchemaCache' => true,
    //'schemaCacheDuration' => 60,
    //'schemaCache' => 'cache',
];