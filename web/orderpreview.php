<?php

include("rcap-fm-api.php");

$user = validate_session();

$poster_id = 0;
if (array_key_exists('poster_id', $_POST) && $_POST['poster_id'])
{
	$poster_id = $_POST['poster_id'];
	$poster = get_poster($poster_id);
}

// check if this is a valid order
if (strtoupper($user['Ordered']) == 'YES' ||    // make sure user hasn't ordered
    $poster_id == 0 || !is_array($poster) ||   // make sure the poster could be found
    $poster['UserId'] != $user['id']            // make sure this user created the poster
)
{
	// if any of the conditions fail, just bounce back to the main menu
	header("Location: " . BASE_URL.'/index.php');
	exit;
}

show_page("orderpreview.tpl.php", array(
	'user' => $user,
	'poster' => $poster
));

?>