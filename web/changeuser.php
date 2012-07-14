<?php

include("rcap-fm-api.php");

$user = validate_session();
$show_passform = true;
$show_infoform = true;
$msg = '';
$saved = false;

if (isset($_POST['act']) && $_POST['act'] == 'changepass')
{
	$show_infoform = false;
	if (!isset($_POST['oldpass']) || !isset($_POST['newpass1']) || !isset($_POST['newpass2']))
	{
		$msg = "To change your password, please fill in all three fields.";
	}
	else if ($_POST['newpass1'] != $_POST['newpass2'])
	{
		$msg = "New passwords do not match.";
	}
	else if (strlen($_POST['newpass1']) < 5 || strlen($_POST['newpass1']) > 20)
	{
		$msg = "Passwords must be at least 5 characters long and less than 20 characters. Password should contain a mix of letters, numbers, and symbols.";
	}
	else if (check_credentials($user['Username'], $_POST['oldpass']))
	{
		$fx_u = fm_connect(FM_TABLE_USERINFO);
		$fx_u->AddDBParam('-recid', $user['RecId']);
		$fx_u->AddDBParam('Password', $_POST['newpass1']);
		$fx_u_result = $fx_u->FMEdit(true, 'full', false);
		$msg = "Password has been changed.";
		$show_infoform = true;
		$saved = true;
	}
	else
	{
		$msg = "Current password is incorrect.";
	}
}
elseif (isset($_POST['act']) && $_POST['act'] == 'changeinfo')
{
	//$show_passform = false;
	$fx_u = fm_connect(FM_TABLE_USERINFO);
	$fx_u->AddDBParam('-recid', $user['RecId']);
	if($_POST['Name'] != "")
		$fx_u->AddDBParam('Name', $_POST['Name']);
	if($_POST['Affiliation'] != "")
		$fx_u->AddDBParam('Affiliation', $_POST['Affiliation']);
	if($_POST['Address'] != "")
		$fx_u->AddDBParam('Mailing Address', $_POST['Address']);
	if($_POST['State'] != "")
		$fx_u->AddDBParam('State', $_POST['State']);
	if($_POST['City'] != "")
		$fx_u->AddDBParam('City', $_POST['City']);
	if($_POST['Zip'] != "")
		$fx_u->AddDBParam('Zip', $_POST['Zip']);
	if($_POST['PhoneNumber'] != "")
		$fx_u->AddDBParam('Phone Number', $_POST['PhoneNumber']);
	if($_POST['Email'] != "")
		$fx_u->AddDBParam('Email Address', $_POST['Email']);
	$fx_u_result = $fx_u->FMEdit(true, 'full', false);
	$msg = "Contact information has been updated.";
	// refresh user info for display
	$user = get_user_info($user['id']);
	$saved = true;
}

show_page("changeuser.tpl.php", array(
	'user' => $user,
	'show_pass' => $show_passform,
	'show_info' => $show_infoform,
	'msg' => $msg,
	'saved' => $saved
));

?>