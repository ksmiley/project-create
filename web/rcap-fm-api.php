<?php
/******************************************
 *          CONFIGURATION SECTION         *
 ******************************************/

/* Filemake connection config */
define('FM_IP', '127.0.0.1');
define('FM_PORT', 80);
define('FM_TYPE', 'FMPro7');
define('FM_USER', 'userhere');
define('FM_PASS', 'passhere');
define('FM_DATABASE', 'RCAP.fp7');
define('FM_TABLE_USERINFO', 'UserInformation');
define('FM_TABLE_ORDERS', 'Order');

/* base URL for the site, without trailing slash */
define('BASE_URL', 'http://localhost/rcap');

define('IMAGE_PREVIEW_URL', BASE_URL.'/preview');

/* base filesystem path for the site, without trailing slash */
define('BASE_PATH', '/Library/WebServer/Documents/RCAP');
/* full path to page templates, without trailing slash */
define('TEMPLATE_PATH', BASE_PATH.'/templates');
/* full include path for libraries such as FX and Savant, without trailing slash */
define('INCLUDE_PATH', BASE_PATH.'/inc');
/* full path to upload images to, without trailing slash */
define('IMAGE_UPLOAD_PATH', BASE_PATH.'/preview');

/* short name to use for the session cookie sent to the user's browser */
define('COOKIE_NAME', 'postermaker_sess');

/******************************************
 *            END CONFIGURATION           *
 ******************************************/

// add the include path defined above to the beginning of the search list
set_include_path(INCLUDE_PATH . PATH_SEPARATOR . get_include_path());

// pull in FX library files for connecting to Filemaker
require_once('FX.php');
require_once('FX_Error.php');
require_once('FX_constants.php');
// pull in Savant3 library for simple templating
require_once('Savant3.php');

// constants for Filemaker error codes that are used frequently
define('FM_STATUS_OK', 0);
define('FM_STATUS_NO_RECORDS', 401);

// returns an FX object connected to the given table in the Filemaker database
function fm_connect($table)
{
	$fx = new FX(FM_IP, FM_PORT, FM_TYPE);
	$fx->SetDBUserPass(FM_USER, FM_PASS);
	$fx->SetDBData(FM_DATABASE, $table, 'All');
	$fx->FlattenInnerArray();
	return $fx;
}

// should be called at the beginning of every protected page. if a valid
// session exists, it returns an array of info about the currently logged-in
// user. if the user isn't logged in, then the default behavior is to 
// stop page execution and redirect to the login page. if $auto_redirect is
// false, then the function will return false for invalid users.
function validate_session($auto_redirect=true)
{
	session_name(COOKIE_NAME);
	if (!session_id())  session_start();
	if (empty($_SESSION['user_id']))
	{
		// user isn't logged in, so bounce to the login page
		if ($auto_redirect)
		{
			header("Location: " . BASE_URL."/login.php?return=".urlencode($_SERVER['REQUEST_URI']));
			exit;
		}
		else
		{
			return false;
		}
	}
	else
	{
		return get_user_info($_SESSION['user_id']);
	}
}

// checks the user credentials, presumably presented by a login request.
// returns an array of user info if the credentials are valid, or false
// if they are invalid.
function check_credentials($user, $pass, $setup_session=false)
{
	$fx = fm_connect(FM_TABLE_USERINFO);
	$fx->AddDBParam('Username', $user, 'eq');
	$fx->AddDBParam('Password', $pass, 'eq');
	$results = $fx->FMFind();
	if ($results['errorCode'] == FM_STATUS_OK)
	{
		if ($setup_session)
		{
			// credentials are correct, so pull out the user info 
			// and setup the session
			$user = _extract_user_info($results);
			session_name(COOKIE_NAME);
			if (!session_id())  session_start();
			$_SESSION['user_id'] = $user['id'];
			return $user;
		}
		else
		{
			return true;
		}
	}
	else if ($results['errorCode'] == FM_STATUS_NO_RECORDS)
	{
		// bad credentials
		return false;
	}
	else
	{
		// DB error
		bail_on_error("Database is not responding", $results['errorCode']);
	}
}

// ends the current session, making the user be logged out
function do_logout()
{
	session_name(COOKIE_NAME);
	if (!session_id())  session_start();
	session_destroy();
}

// given a numeric user_id, returns an array of info about the user
function get_user_info($user_id)
{
	$fx = fm_connect(FM_TABLE_USERINFO);
	$fx->AddDBParam('id', $user_id, 'eq');
	$results = $fx->FMFind();
	if ($results['errorCode'] == FM_STATUS_OK)
	{
		// user found, so pull the data down
		return _extract_user_info($results);
	}
	else if ($results['errorCode'] == FM_STATUS_NO_RECORDS)
	{
		// user not found
		return false;
	}
	else
	{
		// DB error
		bail_on_error("Database is not responding", $results['errorCode']);
	}
}

function get_posters_by_user($user_id, $sort_order='descend')
{
	$fx = fm_connect(FM_TABLE_ORDERS);
	$fx->AddDBParam('UserId', $user_id, 'eq');
	$fx->AddSortParam('id', $sort_order);
	$results = $fx->FMFind();
	if ($results['errorCode'] == FM_STATUS_NO_RECORDS)
	{
		// no posters found
		return array();
	}
	else if ($results['errorCode'] != FM_STATUS_OK)
	{
		// DB error
		bail_on_error("Database is not responding", $results['errorCode']);	
	}
	// found posters, so extract the data
	$posters = array();
	foreach ($results['data'] as $rec_key => $record)
	{
		$posters[] = _extract_poster_info($rec_key, $record);
	}
	return $posters;
}

function get_poster($poster_id)
{
	$fx = fm_connect(FM_TABLE_ORDERS);
	$fx->AddDBParam('id', $poster_id, 'eq');
	$results = $fx->FMFind();
	if ($results['errorCode'] == FM_STATUS_NO_RECORDS)
	{
		// poster not found
		return null;
	}
	else if ($results['errorCode'] != FM_STATUS_OK)
	{
		// DB error
		bail_on_error("Database is not responding", $results['errorCode']);	
	}
	// found the poster, so extract the data
	$temp=array_keys($results['data']);  // workaround PHP BS
	$rec_key = array_shift($temp);
	return _extract_poster_info($rec_key, $results['data'][$rec_key]);
}

// stops page execution and displays an error page asking the user to 
// report the problem to tech support. optionally takes a custom message
// and error code.
function bail_on_error($msg="", $code="")
{
	show_page("fatal_error.tpl.php", array('error_msg' => $msg, 'error_code' => $code));
	exit;
}

// function to make displaying a page with a Savant template even quicker
function show_page($template, $vars = array())
{
	$T = new Savant3(array('template_path' => array(TEMPLATE_PATH)));
	foreach ($vars as $k => $v)
	{
		$T->assign($k, $v);
	}
	$T->display($template);
}

function translate_groupname($val)
{
	$names = array(
		'STDs' => 'STDs',
		'HIV' => 'HIV',
		'MSM' => 'MSM (men who have sex with men)',
		'Heterosexuals' => 'Heterosexuals',
		'IVDrugUsers' => 'Injection Drug Users',
		'Youth' => 'Youth',
		'Caucasian' => 'White/Caucasian',
		'AfricanAmerican' => 'Black/African-American',
		'Hispanic' => 'Hispanic/Latino',
		'NativeAmerican' => 'American Indian/Alaskan Native',
		'Other' => 'Other'
	);
	return array_key_exists($val, $names) ? $names[$val] : 'Unknown';
}


/************************/
/*  INTERNAL FUNCTIONS  */
/************************/

function _extract_poster_info($rec_key, $record)
{
	$temp = explode(".", $rec_key);  // workaround PHP BS
	$rec_id = array_shift($temp);
	$one_poster = array('RecId' => $rec_id);
	$fetch_keys = array(
		"Status", "FilePath", "Name", "Date", "Modification Date",
		"Modification Time", "Creation Time", "Creation Date",
		"Affiliation", "Email Address", "Mailing Address", "Phone Number",
		"Approve", "id", "Poster Text 1", "Poster Text 2", "Poster Text 3",
		"Poster Size", "Paper Type", "State", "City", "Zip", "Reject", 
		"Quantity", "Template", "UserId", "Target Group 1", "Target Group 2",
		"Target Group 3"
	);
	foreach ($fetch_keys as $key)
	{
		$one_poster[$key] = $record[$key][0];
	}
	return $one_poster;
}

// used by check_credentials and get_user_info to pull user data from a
// successful FM query response and return it as an array
function _extract_user_info($results)
{
	$temp=array_keys($results['data']);  // workaround PHP BS
	$rec_key = array_shift($temp);
	$data = $results['data'][$rec_key];
	
	$temp = explode(".", $rec_key);  // workaround PHP BS
	$rec_id = array_shift($temp);
	$info = array('RecId' => $rec_id);
	$fetch_keys = array(
		"id", "Name", "Affiliation", "Mailing Address", "Email Address",
		"Phone Number", "Date", "Modification Time", "Modification Date",
		"Creation Time", "Creation Date", "Username", "State", "City",
		"Zip", "Ordered", "PostersMade", "Poster Selected", "Survey Completed"
	);
	foreach ($fetch_keys as $key)
	{
		$info[$key] = $data[$key][0];
	}
	return $info;
}

?>