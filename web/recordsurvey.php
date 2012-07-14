<?php

include("rcap-fm-api.php");

// this script reads the session cookie, marks the current user as having 
// completed the survey, and returns a 1x1 transparent gif. it's meant to
// be included from the last page of the Qualtrics survey.
$user = validate_session(false);
if (is_array($user))
{
	$fx = fm_connect(FM_TABLE_USERINFO);
	$fx->AddDBParam('-recid', $user['RecId']);
	$fx->AddDBParam('Survey Completed', 'Yes');
	$fx_result = $fx->FMEdit(true, 'full', false);
}

$trans_gif_64 = "R0lGODlhAQABAJEAAAAAAP///////wAAACH5BAEAAAIALAAAAAABAAEAAAICVAEAOw==";
header("Content-type: image/gif");
print(base64_decode($trans_gif_64));
exit;

?>