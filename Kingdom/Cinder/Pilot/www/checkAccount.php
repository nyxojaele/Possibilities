<?php
//Functions
include_once 'scripts/account_functions.php';
//Startup
include_once 'scripts/connect_to_mysql.php';

$username = $_POST['username'];
$success = 0;

$exists = AccountExists($username);
if ($exists == -1)
{
	print "Success=$success&Error='Unable to check account at this time'";
	return;
}
$success = 1;
print "Success=$success&Result=$exists&Username=$username";
return;
?>