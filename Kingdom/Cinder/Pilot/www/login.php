<?php
//Functions
include_once 'scripts/session_functions.php';
//Startup
include_once 'scripts/connect_to_mysql.php';

$username = $_POST['username'];
$password = $_POST['password'];
$success = 0;


//Check if the username exists yet
$userExistsResults = mysql_query("
    SELECT
        COUNT(Username)
    FROM
        tblUsers
    WHERE
        Username = '$username'
    ");
if (!$userExistsResults)
{
    $error = mysql_error();
    print "Success=$success&Error='$error'";
    return;
}
$userCountRow = mysql_fetch_row($userExistsResults);
$userCount = $userCountRow[0];
if ($userCount == 0)
{
    print "Success=$success&Error='Username doesn't exist. Please register before logging in.'";
    return;
}


//Check if the password is correct
$passwordCorrectResults = mysql_query("
	SELECT
		p_ID
	FROM
		tblUsers
	WHERE
		Username = '$username'
		AND Password = '$password'
	LIMIT 1
	");
if (!$passwordCorrectResults)
{
    print "Success=$success&Error='Error checking password'";
    return;
}
$userIDCount = mysql_num_rows($passwordCorrectResults);
if ($userIDCount == 0)
{
    print "Success=$success&Error='Password incorrect'";
    return;
}
$userIDRow = mysql_fetch_row($passwordCorrectResults);
$userID = $userIDRow[0];

$sessionID = GetExistingSession($userID);
if ($sessionID == 0)
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