<?php
//Functions
include_once 'scripts/session_functions.php';
include_once 'scripts/transaction_functions.php';
//Startup
include_once 'scripts/connect_to_mysql.php';


$requestID = $_POST['requestID'];
$sessionID = $_POST['sessionID'];
$action = $_POST['action'];			//'getall', 'available', 'start', 'update', 'finish', 'reset'

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
	//Retrieve a string that represents all info about all quests for the user
	$questsResults = mysql_query("
		SELECT
			p_ID,
			QuestIndex,
			RequestID,
			Type,
			State
		FROM
			tblQuests
		WHERE
			UserID = $userID
		");
	if (!$questsResults)
	{
		CompleteTransaction("Error in quest getall query");
		return;
	}
	$questString = "";
	$questCount = mysql_num_rows($questsResults);
	if ($questCount != 0)
	{
		$questRow = mysql_fetch_assoc($questsResults);
		while ($questRow)
		{
			if ($questString != "")
				$questString .= "|";
			$pid = $questRow['p_ID'];
			$questType = $questRow['Type'];
			$questString .= "$questType,$pid,${questRow['QuestIndex']},${questRow['State']}";
			switch ($questType)
			{
				case 1:	//QUESTTYPE_REALTIME
					{
						$questResult = mysql_query("
							SELECT
								StartTime
							FROM
								tblRealtimeQuests
							WHERE
								p_ID = $pid
							");
						if ($questResult &&
							mysql_num_rows($questResult) == 1)
						{
							$realtimeQuestRow = mysql_fetch_row($questResult);
							$questString .= ",$realtimeQuestRow[0]";
						}
						break;
					}
				case 2:	//QUESTTYPE_GAMETIME
					{
						$questResult = mysql_query("
							SELECT
								TimeSoFarMs
							FROM
								tblGametimeQuests
							WHERE
								p_ID = $pid
							");
						if ($questResult &&
							mysql_num_rows($questResult) == 1)
						{
							$gametimeQuestRow = mysql_fetch_row($questResult);
							$questString .= ",$gametimeQuestRow[0]";
						}
						break;
					}
				case 3:	//QUESTTYPE_STEP
					{
						$questResult = mysql_query("
							SELECT
								CurrentSteps
							FROM
								tblStepQuests
							WHERE
								p_ID = $pid
							");
						if ($questResult &&
							mysql_num_rows($questResult) == 1)
						{
							$stepQuestRow = mysql_fetch_row($questResult);
							$questString .= ",$stepQuestRow[0]";
						}
						break;
					}
			}
			$questRow = mysql_fetch_assoc($questsResults);
		}
	}
	Output("Result", $questString);
}
else if ($action == 'available')
{
	$newID = ActivateQuest($userID, $requestID);
	if ($newID == -1)
	{
		CompleteTransaction("Can not activate quest");
		return;
	}
	Output("NewID", $newID);
}
else if ($action == 'reset')
{
	//We separate this from everything else because the rows may or may not exist already at this point
	$id = $_POST['id'];
	if (CheckQuestOwnership($userID, $id))	//If the user doesn't own such a quest, it doesn't need reseting
	{
		if (!ResetQuest($userID, $id))
		{
			CompleteTransaction("Can not reset quest");
			return;
		}
	}
}
else
{
	$id = $_POST['id'];
	if (!CheckQuestOwnership($userID, $id))
	{
		CompleteTransaction("Quest doesn't belong to this user");
		return;
	}
	
	if ($action == 'start')
	{
		if (!StartQuest($userID, $id))
		{
			CompleteTransaction("Can not start quest");
			return;
		}
	}
	else if ($action == 'finish')
	{
		if (!FinishQuest($userID, $id))
		{
			CompleteTransaction("Can not finish quest");
			return;
		}
	}
	else if ($action == 'finishrepeatable')
	{
		if (!FinishRepeatableQuest($userID, $id))
		{
			CompleteTransaction("Can not finish repeatable quest");
			return;
		}
	}
	else if ($action == 'update')
	{
		if (!UpdateQuest($userID, $id))
		{
			CompleteTransaction("Can not update quest");
			return;
		}
	}
}
CompleteTransaction(null);	//Success!
return;


function CheckQuestOwnership($userID, $id)
{
	$checkResults = mysql_query("
		SELECT
			COUNT(p_ID)
		FROM
			tblQuests
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
//Returns the p_ID of the newly created quest row, or -1 if it couldn't be created
function ActivateQuest($userID, $requestID)
{
	$type = $_POST['type'];
	$questIndex = $_POST['questIndex'];
	
	//Check if the quest has already been activated or not
	$questResults = mysql_query("
		SELECT
			p_ID
		FROM
			tblQuests
		WHERE
			UserID = $userID
			AND Type = $type
			AND QuestIndex = $questIndex
		");
	if (!$questResults)
		//Error with query
		return -1;
	$questCount = mysql_num_rows($questResults);
	
	mysql_query("START TRANSACTION");
	$commit = true;
	if ($questCount != 0)
	{
		//This is a repeatable quest, and has been completed, so reset it
		$questRow = mysql_fetch_assoc($questResults);
		$thisQuestPid = $questRow['p_ID'];
		
		if (!mysql_query("
			DELETE FROM
				tblQuests
			WHERE
				p_ID = $thisQuestPid
			"))
			$commit = false;
		switch ($type)
		{
			case 1:	//QUESTTYPE_REALTIME
				{
					if (!mysql_query("
						DELETE FROM 
							tblRealtimeQuests
						WHERE
							p_ID = $thisQuestPid
						"))
						$commit = false;
					break;
				}
			case 2:	//QUESTTYPE_GAMETIME
				{
					if (!mysql_query("
						DELETE FROM
							tblGametimeQuests
						WHERE
							p_ID = $thisQuestPid
						"))
						$commit = false;
					break;
				}
			case 3:	//QUESTTYPE_STEP
				{
					if (!mysql_query("
						DELETE FROM
							tblStepQuests
						WHERE
							p_ID = $thisQuestPid
						"))
						$commit = false;
					break;
				}
		}
	}
	
	if (!mysql_query("
		INSERT INTO
			tblQuests (UserID, QuestIndex, Type, State, RequestID)
		VALUES
			($userID, $questIndex, $type, 1, $requestID)
		"))
		//Error with query
		$commit = false;
	$questPid = mysql_insert_id();
	switch ($type)
	{
		case 1:	//QUESTTYPE_REALTIME
			{
				if (!mysql_query("
					INSERT INTO
						tblRealtimeQuests (p_ID, StartTime)
					VALUES
						($questPid, 0)
					"))
					$commit = false;
				break;
			}
		case 2:	//QUESTTYPE_GAMETIME
			{
				if (!mysql_query("
					INSERT INTO
						tblGametimeQuests (p_ID, TimeSoFarMs)
					VALUES
						($questPid, 0)
					"))
					$commit = false;
				break;
			}
		case 3:	//QUESTTYPE_STEP
			{
				if (!mysql_query("
					INSERT INTO
						tblStepQuests (p_ID, CurrentSteps)
					VALUES
						($questPid, 0)
					"))
					$commit = false;
				break;
			}
	}
	
	if (!$commit)
	{
		mysql_query("ROLLBACK");
		return -1;
	}
	mysql_query("COMMIT");
	return $questPid;
}
function StartQuest($userID, $ID)
{
	$actualQuestID = GetActualQuestID($userID, $ID);
	if ($actualQuestID < 0)
		return 0;
	$questType = GetQuestType($actualQuestID);
	if ($questType == -1)
		return 0;
	
	mysql_query("START TRANSACTION");
	$commit = true;

	//Update generic quest state
	$questUpdateResults = mysql_query("
		UPDATE
			tblQuests
		SET
			State = 2
		WHERE
			p_ID = $actualQuestID
		");
	if (!$questUpdateResults)
		$commit = false;
	
	//Update specific quest state
	switch ($questType)
	{
		case 1:	//QUESTTYPE_REALTIME
			{
				$startTime = $_POST['startTime'];
				$realtimeUpdateResults = mysql_query("
					UPDATE
						tblRealtimeQuests
					SET
						StartTime = $startTime
					WHERE
						p_ID = $actualQuestID
					");
				if (!realtimeUpdateResults)
					$commit = false;
				break;
			}
		case 2:	//QUESTTYPE_GAMETIME
			{
				$timeSoFarMs = $_POST['timeSoFarMs'];
				$gametimeUpdateResults = mysql_query("
					UPDATE
						tblGametimeQuests
					SET
						TimeSoFarMs = $timeSoFarMs
					WHERE
						p_ID = $actualQuestID
					");
				if (!gametimeUpdateResults)
					$commit = false;
				break;
			}
		case 3:	//QUESTTYPE_STEP
			{
				$currentSteps = $_POST['currentSteps'];
				$stepUpdateResults = mysql_query("
					UPDATE
						tblStepQuests
					SET
						CurrentSteps = $currentSteps
					WHERE
						p_ID = $actualQuestID
					");
				if (!stepUpdateResults)
					$commit = false;
				break;
			}
	}
	if (!$commit)
	{
		mysql_query("ROLLBACK");
		return 0;
	}
	
	mysql_query("COMMIT");
	return 1;
}
function UpdateQuest($userID, $ID)
{
	$actualQuestID = GetActualQuestID($userID, $ID);
	if ($actualQuestID < 0)
		return 0;
	$questType = GetQuestType($actualQuestID);
	if ($questType == -1)
		return 0;
	
	//Update specific quest state
	switch ($questType)
	{
		case 1:	//QUESTTYPE_REALTIME
			{
				//Nothing to do to update this type- this should never be called
				break;
			}
		case 2:	//QUESTTYPE_GAMETIME
			{
				//Just update the elapsed time to whatever the full time is
				$timeSoFarMs = $_POST['timeSoFarMs'];
				if (!mysql_query("
					UPDATE
						tblGametimeQuests
					SET
						TimeSoFarMs = $timeSoFarMs
					WHERE
						p_ID = $actualQuestID
					"))
					return 0;
				break;
			}
		case 3:	//QUESTTYPE_STEP
			{
				//Just update the current steps to whatever the full amount is
				$currentSteps = $_POST['currentSteps'];
				if (!mysql_query("
					UPDATE
						tblStepQuests
					SET
						CurrentSteps = $currentSteps
					WHERE
						p_ID = $actualQuestID
					"))
					return 0;
				break;
			}
	}
	return 1;
}
function FinishQuest($userID, $ID)
{
	$actualQuestID = GetActualQuestID($userID, $ID);
	if ($actualQuestID < 0)
		return 0;
	$questType = GetQuestType($actualQuestID);
	if ($questType == -1)
		return 0;
	
	mysql_query("START TRANSACTION");
	$commit = true;
	
	//Update generic quest state
	$questUpdateResults = mysql_query("
		UPDATE
			tblQuests
		SET
			State = 3
		WHERE
			p_ID = $actualQuestID
		");
	if (!$questUpdateResults)
		$commit = false;
	
	//Update specific quest state
	switch ($questType)
	{
		case 1:	//QUESTTYPE_REALTIME
			{
				//Nothing to do to finish this type
				break;
			}
		case 2:	//QUESTTYPE_GAMETIME
			{
				//Just update the elapsed time to whatever the full time is
				$timeSoFarMs = $_POST['timeSoFarMs'];
				if (!mysql_query("
					UPDATE
						tblGametimeQuests
					SET
						TimeSoFarMs = $timeSoFarMs
					WHERE
						p_ID = $actualQuestID
					"))
					$commit = false;
				break;
			}
		case 3:	//QUESTTYPE_STEP
			{
				//Just update the current steps to whatever the full amount is
				$currentSteps = $_POST['currentSteps'];
				if (!mysql_query("
					UPDATE
						tblStepQuests
					SET
						CurrentSteps = $currentSteps
					WHERE
						p_ID = $actualQuestID
					"))
					$commit = false;
				break;
			}
	}
	if (!$commit)
	{
		mysql_query("ROLLBACK");
		return 0;
	}
	
	mysql_query("COMMIT");
	return 1;
}
function FinishRepeatableQuest($userID, $ID)
{
	$actualQuestID = GetActualQuestID($userID, $ID);
	if ($actualQuestID < 0)
		return 0;
	$questType = GetQuestType($actualQuestID);
	if ($questType == -1)
		return 0;
	
	mysql_query("START TRANSACTION");
	$commit = true;
	
	//Update generic quest state
	$questUpdateResults = mysql_query("
		UPDATE
			tblQuests
		SET
			State = 1
		WHERE
			p_ID = $actualQuestID
		");
	if (!$questUpdateResults)
		$commit = false;
	
	//Update specific quest state
	switch ($questType)
	{
		case 1:	//QUESTTYPE_REALTIME
			{
				//Just reset the start time
				if (!mysql_query("
					UPDATE
						tblRealtimeQuests
					SET
						StartTime = 0
					WHERE
						p_ID = $actualQuestID
					"))
					$commit = false;
				break;
			}
		case 2:	//QUESTTYPE_GAMETIME
			{
				//Just reset the elapsed time
				if (!mysql_query("
					UPDATE
						tblGametimeQuests
					SET
						TimeSoFarMs = 0
					WHERE
						p_ID = $actualQuestID
					"))
					$commit = false;
				break;
			}
		case 3:	//QUESTTYPE_STEP
			{
				//Just reset the current steps
				if (!mysql_query("
					UPDATE
						tblStepQuests
					SET
						CurrentSteps = 0
					WHERE
						p_ID = $actualQuestID
					"))
					$commit = false;
				break;
			}
	}
	if (!$commit)
	{
		mysql_query("ROLLBACK");
		return 0;
	}
	
	mysql_query("COMMIT");
	return 1;
}
function ResetQuest($userID, $ID)
{
	$actualQuestID = GetActualQuestID($userID, $ID);
	if ($actualQuestID < 0)
		return 0;
	$questType = GetQuestType($actualQuestID);
	if ($questType == -1)
		return 0;
		
	//Remove specific quest data first because of foreign key constraints
	switch ($questType)
	{
		case 1:	//QUESTTYPE_REALTIME
			{
				if (!mysql_query("
					DELETE FROM
						tblRealtimeQuests
					WHERE
						p_ID = $actualQuestID
					"))
					return 0;
				break;
			}
		case 2:	//QUESTTYPE_GAMETIME
			{
				if (!mysql_query("
					DELETE FROM
						tblGametimeQuests
					WHERE
						p_ID = $actualQuestID
					"))
					return 0;
				break;
			}
		case 3:	//QUESTTYPE_STEP
			{
				if (!mysql_query("
					DELETE FROM
						tblStepQuests
					WHERE
						p_ID = $actualQuestID
					"))
					return 0;
				break;
			}
	}
	
	//Remove base quest data
	if (!mysql_query("
		DELETE FROM
			tblQuests
		WHERE
			p_ID = $actualQuestID
		"))
		return 0;
		
	return 1;
}


//Returns the p_ID of the quest in question, or -1 if no such quest exists
function GetActualQuestID($userID, $ID)
{
	//$ID may be either tblQuests.p_ID, or tblQuests.requestID
	//If $ID is negative, then the absolute value of it is tblQuests.requestID,
	//whereas if it is positive, it is tblQuests.p_ID
	if ($ID < 0)
	{
		//RequestID
		$questResults = mysql_query("
			SELECT
				p_ID
			FROM
				tblQuests
			WHERE
				UserID = $userID
				AND requestID = -$ID
			");
		if (!questResults)
			return -1;
		if (mysql_num_rows($questResults) != 1)
			return -1;
		$row = mysql_fetch_row($questResults);
		return $row[0];
	}
	else
	{
		//p_ID
		$questResults = mysql_query("
			SELECT
				p_ID
			FROM
				tblQuests
			WHERE
				UserID = $userID
				AND p_ID = $ID
			");
		if (!$questResults)
			return -1;
		if (mysql_num_rows($questResults) != 1)
			return -1;
		$row = mysql_fetch_row($questResults);
		return $row[0];
	}
}
//Returns the Type column for the given p_ID, or -1 if an error occurred
function GetQuestType($ID)
{
	$questResults = mysql_query("
		SELECT
			Type
		FROM
			tblQuests
		WHERE
			p_ID = $ID
		");
	if (!$questResults)
		return -1;
	if (mysql_num_rows($questResults) != 1)
		return -1;
	$row = mysql_fetch_row($questResults);
	return $row[0];
}
?>