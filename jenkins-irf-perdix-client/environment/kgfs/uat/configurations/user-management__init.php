<?php

/*if (empty($_SERVER['HTTP_ORIGIN'])) {
        ini_set('display_errors', 1);
        ini_set('display_startup_errors', 1);
        error_reporting(E_ALL);
}*/

ob_start("ob_gzhandler");
//header("Access-Control-Allow-Credentials: true");
header("Access-Control-Allow-Headers: Content-Type, accept, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: OPTIONS,GET,POST,PUT");
header("Access-Control-Request-Headers: Content-Type, accept");
header("Access-Control-Expose-Headers: X-Total-Count");
header('Content-Type: application/json');

if (!empty($_SERVER['HTTP_ORIGIN'])) {
        header("Access-Control-Allow-Origin: " . $_SERVER['HTTP_ORIGIN']);
}

if ($_SERVER['REQUEST_METHOD'] == "OPTIONS") {
        die();
}

define('DB_HOST', 'localhost');
define('DB_USER', 'financialForms');
define('DB_PASSWORD', 'financialForms');
define('DB_SCHEMA', 'kgfs_financialForms_uat');

$connection = new mysqli(DB_HOST,DB_USER,DB_PASSWORD) or die ('Could not connect to the server. If this is first time, please reload the page.');

mysqli_autocommit($connection, true);
// echo 'Connected successfully';
