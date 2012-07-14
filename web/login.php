<?php

include("rcap-fm-api.php");

$dest_url = BASE_URL.'/index.php';
if (array_key_exists('return', $_REQUEST) && $_REQUEST['return'])
{
	$dest_url = $_REQUEST['return'];
}
$msg = "";

if (array_key_exists('logout', $_GET) && $_GET['logout'])
{
	do_logout();
	$msg = 'You have been logged out.';
}
else if (array_key_exists('User', $_POST) && array_key_exists('Pass', $_POST) 
         && $_POST['User'] && $_POST['Pass'])
{
	$user = check_credentials($_POST['User'], $_POST['Pass'], true);
	if (is_array($user))
	{
		header("Location: " . $dest_url);
		exit;
	}
	else
	{
		$msg = "Username or password is incorrect.";
	}
}

show_page("login.tpl.php", array(
	'error_msg' => $msg,
	'return_url' => $dest_url
));

?>