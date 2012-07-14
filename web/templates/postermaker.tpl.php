<?php $U = $this->user; ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Project CREATE - Rural Center for AIDS/STD Prevention</title>
<link rel="stylesheet" href="css/rcap.css" media="all" />
<script type="text/javascript" src="js/jquery-1.4.3.min.js"></script>
<script type="text/javascript" src="js/jquery.swfobject.1-1-1.min.js"></script>

<script type="text/javascript">
$(document).ready(function(){
	$("#rcap_header a").click(function() {
		// only warn if navigating away will actually lose data
		if (!$("#postermaker").data("poster-inprogress"))
		{
			return true;
		}
		var msg =
			"Are you sure you want to navigate away from the poster maker program? " + 
			"The poster you are currently working on will be lost. Click 'cancel' to stay on this page."
		;
		if (confirm(msg))
		{
			return true;
		}
		else
		{
			return false;
		}
	});
	$("#postermaker").data("poster-inprogress", false).flash({
		swf: 'PosterMaker.swf',
		width: 980,
		height: 600,
		wmode: 'window',
		encodeParams: false,
		allowScriptAccess: 'always',
		flashVars: {
			id: '<?php echo urlencode($U["id"]) ?>',
			name: '<?php echo urlencode($U["Name"]) ?>',
			address: '<?php echo urlencode($U["Mailing Address"]) ?>',
			city: '<?php echo urlencode($U["City"]) ?>',
			state: '<?php echo urlencode($U["State"]) ?>',
			zip: '<?php echo urlencode($U["Zip"]) ?>',
			email: '<?php echo urlencode($U["Email Address"]) ?>',
			affiliation: '<?php echo urlencode($U["Affiliation"]) ?>',
			phone: '<?php echo urlencode($U["Phone Number"]) ?>',
			ordered: '<?php echo urlencode($U["Ordered"]) ?>',
			surveydone: '<?php echo urlencode($U["Survey Completed"]) ?>',
			sessionid: '<?php echo urlencode(session_id()) ?>'
		}
	});
});
function posterStarted() { $("#postermaker").data("poster-inprogress", true); }
function posterStopped() { $("#postermaker").data("poster-inprogress", false); }
</script>

</head>

<body>

<div id="maincontain">

<div id="rcap_header" class="smaller">
<div id="header_left">
<img src="images/rcaplogoTan.gif" alt="Rural Center for AIDS/STD Prevention" border="0"/></div>
<div id="header_right">
<a href="index.php">Return to Main Menu</a> | <a href="login.php?logout=true">Logout</a>
</div>
</div>

<div id="main">

<div id="postermaker">
<noscript><div id="no-js">You must have Javascript enabled in your Web browser to use the Project CREATE site.</div></noscript>
<p>Adobe Flash is required to use the Project CREATE program. <a href="http://www.adobe.com/go/getflashplayer">Click here to download it</a>.</p>
<p><a href="http://www.adobe.com/go/getflashplayer"><img src="images/160x41_Get_Flash_Player.jpg" alt="Get Adobe Flash Player"></a></p>
</div>

</div>
<div id="footer">
<p>Project CREATE |  create rural education AIDS tailoring effort</p>
</div>

</div>
</body>
</html>
