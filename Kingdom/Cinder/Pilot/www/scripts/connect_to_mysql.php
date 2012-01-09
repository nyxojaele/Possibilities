<?php
// Place db host name. Sometimes "localhost" but
// sometimes looks like this: >>        ??mysql??.someserver.net
$db_host = "localhost";
$db_username = "wonder";
$db_pass = "Imagine1234!";
$db_name = "playground";
// Run the connection here
$dbConnection = mysql_connect("$db_host", "$db_username", "$db_pass");
if (!$dbConnection)
{
    print "Error='Cannot create MySQL Connection'";
    return;
}
if (!mysql_select_db("$db_name"))
{
    print "Error='Cannot select database'";
    return;
}
// Now you can use the variable $dbConnection to connect in your queries
?>