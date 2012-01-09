<?php
//Functions
include_once 'scripts/session_functions.php';
include_once 'scripts/transaction_functions.php';
//Startup
include_once 'scripts/connect_to_mysql.php';

$requestID = $_POST['requestID'];
$sessionID = $_POST['sessionID'];
$action = $_POST['action'];			//'add', 'remove', 'setquest', 'getall'

//Setup our transaction
StartTransaction();

//Print some stuff that's going back no matter what
Output("Action", $action);
Output("RequestID", $requestID);

//On to the meat of the matter~
if (!TouchValidSession($sessionID))
{
	CompleteTransaction("Session timed out.");
	return;
}
$userID = GetUserForSession($sessionID);
if (!$userID)
{
	CompleteTransaction("Unable to retrieve user for session.");
	return;
}

if ($action == 'getall')
{
	//Retrieve a string that represents all info about all minions for the user
	$minionsResults = mysql_query("
		SELECT
			p_ID,
			RequestID,
			Name,
			Sex,
			FighterStat,
			MageStat,
			GathererStat,
			BuilderStat,
			QuestID
		FROM
			tblMinions
		WHERE
			UserID = $userID
		");
	if (!$minionsResults)
	{
		CompleteTransaction("Error in minion getall query");
		return;
	}
	$minionString = "";
	$minionCount = mysql_num_rows($minionsResults);
	if ($minionCount != 0)
	{
		$minionRow = mysql_fetch_assoc($minionsResults);
		while ($minionRow)
		{
			if ($minionString != "")
				$minionString .= "|";
			$pid = $minionRow['p_ID'];
			$minionString .= "1," . $pid . "," . $minionRow['Name'] . "," . $minionRow['Sex'] . "," . $minionRow['FighterStat'] . "," . $minionRow['MageStat'] . "," . $minionRow['GathererStat'] . "," . $minionRow['BuilderStat'] . "," . $minionRow['QuestID'];
			
			$minionRow = mysql_fetch_assoc($minionsResults);
		}
	}
	Output("Result", $minionString);
}
else if ($action == 'add')
{
	$newID = AddMinion($userID, $requestID);
	if ($newID == -1)
	{
		CompleteTransaction("Can not add minion");
		return;
	}
	Output("NewID", $newID);
}
else
{
	$id = $_POST['id'];
	if (!CheckMinionOwnership($userID, $id))
	{
		CompleteTransaction("Minion doesn't belong to this user");
		return;
	}
	
	if ($action == 'remove')
	{
		if (!RemoveMinion($userID, $id))
		{
			CompleteTransaction("Can not remove minion");
			return;
		}
	}
	else if ($action == 'setquest')
	{
		if (!SetQuest($userID, $id))
		{
			CompleteTransaction("Can not set minion quest");
			return;
		}
	}
	else if ($action == 'setStats')
	{
		if (!SetStats($userID, $id))
		{
			CompleteTransaction("Can not set minion stats");
			return;
		}
	}
}
CompleteTransaction(null);	//Success!
return;


function CheckMinionOwnership($userID, $id)
{
	$checkResults = mysql_query("
		SELECT
			COUNT(p_ID)
		FROM
			tblMinions
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
//Returns the p_ID of the newly created minion row, or -1 if it couldn't be created
function AddMinion($userID, $requestID)
{
	$name = $_POST['name'];
	$sex = $_POST['sex'];
	$fighterStat = $_POST['fighterStat'];
	$mageStat = $_POST['mageStat'];
	$gathererStat = $_POST['gathererStat'];
	$builderStat = $_POST['builderStat'];
	
	if (!mysql_query("
		INSERT INTO
			tblMinions (UserID, Name, Sex, FighterStat, MageStat, GathererStat, BuilderStat, QuestID, RequestID)
		VALUES
			($userID, '$name', $sex, $fighterStat, $mageStat, $gathererStat, $builderStat, -1, $requestID)
		"))
		return -1;
	$minionPid = mysql_insert_id();
	return $minionPid;
}
function RemoveMinion($userID, $ID)
{
	$actualMinionID = GetActualMinionID($userID, $ID);
	if ($actualMinionID < 0)
		return 0;
	
	if (!mysql_query("
		DELETE FROM
			tblMinions
		WHERE
			p_ID = $actualMinionID
		"))
		return 0;
		
	return 1;
}
function SetQuest($userID, $ID)
{
	$actualMinionID = GetActualMinionID($userID, $ID);
	if ($actualMinionID < 0)
		return 0;
	
	$questID = $_POST['questId'];
	if (!mysql_query("
		UPDATE
			tblMinions
		SET
			QuestID = $questID
		WHERE
			p_ID = $actualMinionID
		"))
		return 0;
	return 1;
}
function SetStats($userID, $ID)
{
	$actualMinionID = GetActualMinionID($userID, $ID);
	if ($actualMinionID < 0)
		return 0;
	
	$fighterStat = $_POST['fighterStat'];
	$mageStat = $_POST['mageStat'];
	$gathererStat = $_POST['gathererStat'];
	$builderStat = $_POST['builderStat'];
	if (!mysql_query("
		UPDATE
			tblMinions
		SET
			FighterStat = $fighterStat,
			MageStat = $mageStat,
			GathererStat = $gathererStat,
			BuilderStat = $builderStat
		WHERE
			p_ID = $actualMinionID
		"))
		return 0;
	return 1;
}


//Returns the p_ID of the minion in question, or -1 if no such quest exists
function GetActualMinionID($userID, $ID)
{
	//$ID may be either tblMinions.p_ID, or tblMinions.requestID
	//If $ID is negative, then the absolute value of it is tblMinions.requestID,
	//whereas if it is positive, it is tblMinions.p_ID
	if ($ID < 0)
	{
		//RequestID
		$minionResults = mysql_query("
			SELECT
				p_ID
			FROM
				tblMinions
			WHERE
				UserID = $userID
				AND requestID = -$ID
			");
		if (!minionResults)
			return -1;
		if (mysql_num_rows($minionResults) != 1)
			return -1;
		$row = mysql_fetch_row($minionResults);
		return $row[0];
	}
	else
	{
		//p_ID
		$minionResults = mysql_query("
			SELECT
				p_ID
			FROM
				tblMinions
			WHERE
				UserID = $userID
				AND p_ID = $ID
			");
		if (!$minionResults)
			return -1;
		if (mysql_num_rows($minionResults) != 1)
			return -1;
		$row = mysql_fetch_row($minionResults);
		return $row[0];
	}
}
?>