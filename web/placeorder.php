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
    $poster_id == 0 || !is_array($poster) ||    // make sure the poster could be found
    $poster['UserId'] != $user['id']            // make sure this user created the poster
)
{
	// if any of the conditions fail, just bounce back to the main menu
	header("Location: " . BASE_URL.'/index.php');
//	echo "Bouncing! " . $user['Ordered'] . "\n";
//	echo "Poster: " . $poster_id . " (" . $poster . ")\n";
//	echo "You are: " . $user['id'] . " but I need " . $poster['UserId'] . "\n";
	exit;
}

// looks legit. now run two updates: one update to put the shipping info
// in with the order, and another to mark that the user has ordered this
// poster.
$fx_o = fm_connect(FM_TABLE_ORDERS);
$fx_o->AddDBParam('-recid', $poster['RecId']);
#if($_POST['Quantity'] != "")
#	$fx_o->AddDBParam('Quantity', $_POST['Quantity']);
# NOTE: quantity is locked to 1 for the pilot
$fx_o->AddDBParam('Quantity', 1);
if($_POST['Name'] != "")
	$fx_o->AddDBParam('Name', $_POST['Name']);
if($_POST['Address'] != "")
	$fx_o->AddDBParam('Mailing Address', $_POST['Address']);
if($_POST['State'] != "")
	$fx_o->AddDBParam('State', $_POST['State']);
if($_POST['City'] != "")
	$fx_o->AddDBParam('City', $_POST['City']);
if($_POST['Zip'] != "")
	$fx_o->AddDBParam('Zip', $_POST['Zip']);
if($_POST['Email'] != "")
	$fx_o->AddDBParam('Email Address', $_POST['Email']);
if($_POST['Affiliation'] != "")
	$fx_o->AddDBParam('Affiliation', $_POST['Affiliation']);
if($_POST['PhoneNumber'] != "")
	$fx_o->AddDBParam('Phone Number', $_POST['PhoneNumber']);
$fx_o_result = $fx_o->FMEdit(true, 'full', false);

$fx_u = fm_connect(FM_TABLE_USERINFO);
$fx_u->AddDBParam('-recid', $user['RecId']);
$fx_u->AddDBParam('Ordered', 'Yes');
$fx_u->AddDBParam('Poster Selected', $poster_id);
$fx_u_result = $fx_u->FMEdit(true, 'full', false);

show_page("placeorder.tpl.php", array(
	'user' => $user,
	'poster' => $poster
));

?>