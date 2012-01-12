<?php
//Functions
include_once 'scripts/account_functions.php';
include_once 'scripts/session_functions.php';
//Startup
include_once 'scripts/connect_to_mysql.php';

$username = $_POST['username'];
$password = $_POST['password'];
$success = 0;


//Check DB Version
$expectedDBVersion = $_POST['DBVersion'];
if (!CheckDBVersion($expectedDBVersion))
{
	//Invalid DB Version
	print "Success=$success&Error='Invalid DB version'";
	return;
}


//Check if username is being used already
if (AccountExists($username) != 0)
{
    print "Success=$success&Error='Username already in use'";
    return;
}


//Login
$userID = CreateNewAccount($username, $password);
if ($userID == -1)
{
	print "Success=$success&Error='Unable to create new user'";
	return;
}
//There will never be an existing session for a new user, no sense in even checking for it
$sessionID = CreateNewSession($userID);
if ($sessionID == 0)
{
    print "Success=$success&Error='Could not acquire session'";
    return;
}
if (!InitSession($userID, $sessionID))
{
	print "Success=$success&Error='Could not init session'";
	return;
}

//We have a session, return it
TouchSession($sessionID);
$success = 1;
print "Success=$success&SessionID=$sessionID&Username=$username";
?>