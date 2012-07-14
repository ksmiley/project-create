<?php

include("rcap-fm-api.php");

$user = validate_session();

$posters = get_posters_by_user($user['id']);

show_page("main_menu.tpl.php", array(
	'user' => $user,
	'has_posters' => (count($posters) > 0 ? true : false),
	'has_ordered' => (strtoupper($user['Ordered']) == 'YES' ? true : false)
));

?>