<?php
//Functions
include_once 'scripts/session_functions.php';
//Startup
include_once 'scripts/connect_to_mysql.php';

$requestID = $_POST['requestID'];
$sessionID = $_POST['sessionID'];
$action = $_POST['action'];			//'get' or 'set'

if (!TouchValidSession($sessionID))
{
    print "Action=$action&RequestID=$requestID&Success=0&Error='Session timed out.'";
	return;
}
$userID = GetUserForSession($sessionID);
if (!$userID)
{
	print "Action=$action&RequestID=$requestID&Success=0&Error='Unable to retrieve user for session.'";
	return;
}

if ($action == 'getall')
{
	//Retrieve a string that represents all info about all resources for the user
	$resourceResults = mysql_query("
			SELECT
				p_ID,
				Type,
				Value
			FROM
				tblResources
			WHERE
				UserID = $userID
			");
	if (!$resourceResults)
	{
		print "Action=$action&RequestID=$requestID&Success=0&Error='Error in resource getall query.'";
		return;
	}
	$resourceString = "";
	$resourceCount = mysql_num_rows($resourceResults);
	if ($resourceCount != 0)
	{
		$resourceRow = mysql_fetch_assoc($resourceResults);
		while ($resourceRow)
		{
			if ($resourceString != "")
				$resourceString .= "|";
			$resourceString .= $resourceRow['Type'] . "," . $resourceRow['p_ID'] . "," . $resourceRow['Value'];
			
			$resourceRow = mysql_fetch_assoc($resourceResults);
		}
	}
	print "Action=$action&RequestID=$requestID&Success=1&Result=$resourceString";
	return;
}
else if ($action == 'set')
{
	$ID = $_POST['id'];					//p_ID
	if ($ID == '-1')
	{
		print "Action=$action&RequestID=$requestID&Success=0&Error='Invalid resource ID $ID'";
		return;
	}
	$type = $_POST['type'];				//Type
	$value = $_POST['value'];			//Value
	if (!mysql_query("
			UPDATE
				tblResources
			SET
				Value = $value
			WHERE
				p_ID = $ID
				AND Type = $type
				AND UserID = $userID
			"))
	{
		print "Action=$action&RequestID=$requestID&Success=0&Error='Error in resource set query.'";
		return;
	}
	print "Action=$action&RequestID=$requestID&Success=1";
	return;
}
?>