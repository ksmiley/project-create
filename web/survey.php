<?php

include("rcap-fm-api.php");

$user = validate_session();

// if the user has already completed the survey, bounce along to the
// "posters you've made" screen
if (strtoupper($user['Survey Completed']) == 'YES')
{
	header("Location: " . BASE_URL.'/reviewposters.php');
	exit;
}

// check whether the user has created any posters. if not, they shouldn't
// take the survey yet, so redirect to the main menu
$posters = get_posters_by_user($user['id']);
if (count($posters) == 0)
{
	header("Location: " . BASE_URL.'/index.php');
	exit;
}

$poster_id = "";
if (array_key_exists('PosterID', $_GET) && $_GET['PosterID'])
{
	$poster_id = $_GET['PosterID'];
}

show_page("survey.tpl.php", array(
	'user' => $user,
	'poster_id' => $poster_id
));

?>