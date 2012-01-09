<?php
//Functions
include_once 'scripts/session_functions.php';
//Startup
include_once 'scripts/connect_to_mysql.php';

$requestID = $_POST['requestID'];
$sessionID = $_POST['sessionID'];
$action = $_POST['action'];			//'place', 'remove', 'move', 'getall'

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
	//Retrieve a string that represents all info about all buildings for the user
	$buildingsResults = mysql_query("
		SELECT
			p_ID,
			ClassTypeID,
			PosX,
			PosY,
			CurrentHealth
		FROM
			tblBuildings
		WHERE
			UserID = $userID
		");
	if (!$buildingsResults)
	{
		print "Action=$action&RequestID=$requestID&Success=0&Error='Error in building getall query'";
		return;
	}
	$buildingString = "";
	$buildingCount = mysql_num_rows($buildingsResults);
	if ($buildingCount != 0)
	{
		$buildingRow = mysql_fetch_assoc($buildingsResults);
		while ($buildingRow)
		{
			if ($buildingString != "")
				$buildingString .= "|";
			$buildingString .= $buildingRow['ClassTypeID'] . "," . $buildingRow['p_ID'] . "," . $buildingRow['PosX'] . "," . $buildingRow['PosY'] . "," . $buildingRow['CurrentHealth'];
			
			$buildingRow = mysql_fetch_assoc($buildingsResults);
		}
	}
	print "Action=$action&RequestID=$requestID&Success=1&Result=$buildingString";
	return;
}
else if ($action == 'place')
{
	$classTypeID = $_POST['classTypeID'];	//Building class type identifier
	$toXPos = $_POST['toX'];				//XPos to place at
	$toYPos = $_POST['toY'];				//YPOs to place at
	$health = $_POST['health'];				//Current Health
	
	if (!PlaceBuilding($userID, $classTypeID, $toXPos, $toYPos, $health))
	{
		print "Action=$action&RequestID=$requestID&Success=0&Error='Error in place query'";
		return;
	}
	$newID = mysql_insert_id();
	print "Action=$action&RequestID=$requestID&Success=1&NewID=$newID";
}
else
{
	$id = $_POST['id'];

	if (!CheckBuildingOwnership($userID, $id))
	{
		print "Action=$action&RequestID=$requestID&Success=0&Error='Building doesn't belong to this user'";
		return;
	}
	
	if ($action == 'remove')
	{
		$id = $_POST['id'];					//DB ID
		if (!RemoveBuilding($id))
		{
			print "Action=$action&RequestID=$requestID&Success=0&Error='Error in remove query'";
			return;
		}
		print "Action=$action&RequestID=$requestID&Success=1";
	}
	else if ($action == 'move')
	{
		$id = $_POST['id'];					//DB ID
		$toXPos = $_POST['toX'];			//XPos to move to
		$toYPos = $_POST['toY'];			//YPos to move to
		
		if (!MoveBuilding($id, $toXPos, $toYPos))
		{
			print "Action=$action&RequestID=$requestID&Success=0&Error='Error in move query'";
			return;
		}
		print "Action=$action&RequestID=$requestID&Success=1";
	}
}
return;


function CheckBuildingOwnership($userID, $id)
{
	$checkResults = mysql_query("
			SELECT
				COUNT(p_ID)
			FROM
				tblBuildings
			WHERE
				p_ID = $id
				AND UserID = $userID
			");
	if (!$checkResults)
		//Error with query
		return 0;
	$checkCount = mysql_num_rows($checkResults);
	if ($checkCount == 0)
		return 0;
	return 1;
	
}
function PlaceBuilding($userID, $classTypeID, $toXPos, $toYPos, $currentHealth)
{
	if (!mysql_query("
			INSERT INTO
				tblBuildings (UserID, ClassTypeID, PosX, PosY, CurrentHealth)
			VALUES
				($userID, $classTypeID, $toXPos, $toYPos, $currentHealth)
			"))
		//Error with query
		return 0;
	return 1;
}
function RemoveBuilding($id)
{
	if (!mysql_query("
			DELETE FROM
				tblBuildings
			WHERE
				p_ID = $id
			"))
		return 0;
	return 1;
}
function MoveBuilding($id, $toXPos, $toYPos)
{
	if (!mysql_query("
			UPDATE
				tblBuildings
			SET
				PosX = $toXPos,
				PosY = $toYPos
			WHERE
				p_ID = $id
			"))
		return 0;
	return 1;
}
?>