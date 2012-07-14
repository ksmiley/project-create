<?php

include("rcap-fm-api.php");

$user = validate_session();

show_page("postermaker.tpl.php", array(
	'user' => $user
));

?>