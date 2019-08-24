<?php
function ConnectDb() {
        /*$dbhost="10.60.40.114";
        $dbuser="financialForms";
        $dbpass="senseidb@123";

        $framework_db="framework";      */

        $dbhost="localhost";
        $dbuser="financialForms";
        $dbpass="financialForms";

        $framework_db="kgfs_financialForms_uat";

        $dbConnection = new PDO("mysql:host=$dbhost;dbname=$framework_db", $dbuser, $dbpass);
        $dbConnection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $dbConnection;
}

function ConnectUAT() {
        $dbhost="localhost";
        $dbuser="financialForms";
        $dbpass="financialForms";

        $framework_db="kgfs_financialForms_uat";

        $dbConnection = new PDO("mysql:host=$dbhost;dbname=$framework_db", $dbuser, $dbpass);
        $dbConnection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $dbConnection;
}
?>
