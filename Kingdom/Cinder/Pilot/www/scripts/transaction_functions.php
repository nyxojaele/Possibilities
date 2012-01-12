<?php
$output = array();


function StartTransaction()
{
	mysql_query("START TRANSACTION");
}
function Output($variable, $value)
{
	global $output;
	$output[$variable] = $value;
}
function CompleteTransaction($errorMessage)
{
	global $output;
	if ($errorMessage)
	{
		mysql_query("ROLLBACK");
		Output("Success", 0);
		Output("Error", "'" . $errorMessage . "'");
	}
	else
	{
		mysql_query("COMMIT");
		Output("Success", 1);
	}
	$started = false;
	foreach ($output as $key => $value)
	{
		if (!$started)
		{
			print "$key=$value";
			$started = true;
		}
		else
			print "&$key=$value";
	}
}
?>