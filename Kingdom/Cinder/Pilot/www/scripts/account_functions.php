<?php
//Returns whether an account by the given name exists or not (1 or 0), or -1 for error
function AccountExists($username)
{
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
		return -1;
	$userCountRow = mysql_fetch_row($userExistsResults);
	$userCount = $userCountRow[0];
	if ($userCount == 0)
		return 0;
	else
		return 1;
}

function CreateNewAccount($username, $password)
{
	$commit = "COMMIT";
	mysql_query("START TRANSACTION");
	
	//Create new user
	if (!mysql_query("
		INSERT INTO
			tblUsers (Username, Password)
		VALUES
			('$username', '$password')
		"))
		$commit = "ROLLBACK";
	$userID = mysql_insert_id();
	
	//Fill default resources (order: wood, gold, food)
	if (!mysql_query("
		INSERT INTO
			tblResources (UserID, Type, Value)
		VALUES
			($userID, 1, 50),
			($userID, 2, 50),
			($userID, 3, 50)
		"))
		$commit = "ROLLBACK";
	
	//Fill default minion
	if (!mysql_query("
		INSERT INTO
			tblMinions (UserID, Name, FighterStat, MageStat, GathererStat, BuilderStat, QuestID, RequestID, Sex)
		VALUES
			($userID, 'Minion', 1, 1, 1, 1, -1, null, 1)
		"))
		$commit = "ROLLBACK";
	
	//Fill default quests (order: QUEST_RESOURCEWOOD1, QUEST_RESOURCEGOLD1, QUEST_RESOURCEFOOD1)
	if (!mysql_query("
		INSERT INTO
			tblQuests (UserID, QuestIndex, Type, State, RequestID)
		VALUES
			($userID, 0, 2, 1, null),
			($userID, 1, 2, 1, null),
			($userID, 2, 2, 1, null)
		"))
		$commit = "ROLLBACK";
	
	mysql_query("$commit");
	return $userID;
}
?>