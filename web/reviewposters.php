<?php

include("rcap-fm-api.php");

$user = validate_session();

$can_order = true;
if (strtoupper($user['Ordered']) == 'YES')
{
	$can_order = false;
}

$posters = get_posters_by_user($user['id']);

show_page("reviewposters.tpl.php", array(
	'user' => $user,
	'posters' => $posters,
	'can_order' => $can_order
));

?>