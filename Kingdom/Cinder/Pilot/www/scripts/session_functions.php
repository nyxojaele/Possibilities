<?php
//Returns an existing, valid sessionID, or 0 if no such sessionID exists
function GetExistingSession($userID)
{
    $ret = 0;

    $sessionResults = mysql_query("
        SELECT
            s.p_ID
        FROM
            tblSessions s
            INNER JOIN tblUsers u ON u.LastSessionID = s.p_ID
        WHERE
			u.p_ID = $userID
            AND ADDTIME(s.TouchTime, '00:15:00.000000') > CURRENT_TIMESTAMP
        LIMIT 1
        ");
	if (!$sessionResults)
		//Error with query
		return $ret;
    $sessionIDCount = mysql_num_rows($sessionResults);
    if ($sessionIDCount == 0)
        //First login, or last session's touch time is more than 15 mins ago
        return $ret;

    //If we got this far, we have an existing session
    $sessionIDRow = mysql_fetch_row($sessionResults);
    $ret = $sessionIDRow[0];
    return $ret;
}

//Returns the user associated with sessionID, if sessionID represents a valid session
function GetUserForSession($sessionID)
{
	$userResults = mysql_query("
		SELECT
			u.p_ID
		FROM
			tblSessions s
			INNER JOIN tblUsers u ON u.LastSessionID = s.p_ID
		WHERE
			s.p_ID = $sessionID
			AND ADDTIME(s.TouchTime, '00:15:00.000000') > CURRENT_TIMESTAMP
		LIMIT 1
		");
	if (!$userResults)
		//Error with query
		return 0;
	$userIDCount = mysql_num_rows($userResults);
	if ($userIDCount == 0)
		//This session's touch time is more than 15 mins ago
		return 0;
	
	//If we got this far, the current session is valid, and we have a user for it
	$userIDRow = mysql_fetch_row($userResults);
	return $userIDRow[0];
}

//Returns a newly created sessionID, or 0 if an error occurred
function CreateNewSession($userID)
{
    //New session
    $commit = "COMMIT";
    mysql_query("START TRANSACTION");

    if (!mysql_query("
        INSERT INTO
            tblSessions (TouchTime)
        VALUES
            (CURRENT_TIMESTAMP)
        "))
        $commit = "ROLLBACK";

    //Connect session to user
    $sessionID = mysql_insert_id();
    if (!mysql_query("
        UPDATE
            tblUsers
        SET
            LastSessionID = $sessionID
        WHERE
            p_ID = $userID
        "))
        $commit = "ROLLBACK";

    mysql_query("$commit");
    return $sessionID;
}

//Initializes a session before use- this is important to avoid race conditions and such while the user is playing
//Returns success or not
function InitSession($userID, $sessionID)
{
	//Quests - Remove all requestIDs, as they all have p_IDs now, and the client isn't out of sync
	if (!mysql_query("
		UPDATE
			tblQuests
		SET
			RequestID = null
		WHERE
			UserID = $userID
		"))
		return 0;
	return 1;
}

//This function should be called frequently in order to keep a session alive
function TouchSession($sessionID)
{
    mysql_query("
        UPDATE
            tblSessions
        SET
            TouchTime = CURRENT_TIMESTAMP
        WHERE
            p_ID = $sessionID
        ");
}

//This function should be called at the start of any calls to validate the requested session
function TouchValidSession($sessionID)
{
    $sessionResults = mysql_query("
        SELECT
            p_ID
        FROM
            tblSessions
        WHERE
			ADDTIME(TouchTime, '00:15:00.000000') > CURRENT_TIMESTAMP
        LIMIT 1
        ");
	if (!$sessionResults)
		//Error with query
		return 0;
    $sessionIDCount = mysql_num_rows($sessionResults);
    if ($sessionIDCount == 0)
		//No valid session
		return 0;
	
	//If we got this far, there is a valid session
	TouchSession($sessionID);
	return 1;
}
?>