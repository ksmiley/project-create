<?php

include("rcap-fm-api.php");

ini_set('display_errors', false);   // so errors don't get sent back and confuse Flash

// gateway has to provide this through a param instead of relying on the
// cookie working correctly when coming from the Flash program
if (array_key_exists('sessionid', $_POST) && $_POST['sessionid'])
{
	session_name(COOKIE_NAME);
	session_id($_POST['sessionid']);
	session_start();
}
$user = validate_session(false);
if (!is_array($user))
{
	echo 'ERROR';
}
else
{
	$fx_insert = fm_connect(FM_TABLE_ORDERS);
	$fx_insert->AddDBParam('UserID', $_POST['id']);
	$fx_insert->AddDBParam('Template', $_POST['tmplset']);
	$fx_insert->AddDBParam('Poster Size', $_POST['size']);
	$fx_insert->AddDBParam('Target Group 1', $_POST['group1']);
	$fx_insert->AddDBParam('Target Group 2', $_POST['group2']);
	$fx_insert->AddDBParam('Target Group 3', $_POST['group3']);
	//$fx_insert->AddDBParam('Paper Type', $_POST['quality']);
	//$fx_insert->AddDBParam('Quantity', $_POST['quantity']);
	for ($i = 0; $i < 10; $i++)
	{
		if (array_key_exists('text' . $i, $_POST))
		{
			$fx_insert->AddDBParam('Poster Text ' . $i, $_POST['text' . $i]);
		}
	}

	$newRecord = $fx_insert->FMNew(true, 'full', false);

	$newKey = array_keys($newRecord['data']);
	$newId = $newRecord['data'][ $newKey[0] ]['id'];
	$filename = IMAGE_UPLOAD_PATH . '/' . $newId . '.jpg';

	rename($_FILES['imagePreview']['tmp_name'], $filename);

	echo 'OK ' . $newId;
}

?>