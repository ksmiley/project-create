<?php
$U = $this->user;
$this->display("header.tpl.php");
?>

<div id="navcontainer">
<p class="welcome-banner">Welcome, <strong><?php $this->eprint($U['Name']) ?></strong></p>

<dl>
<dt>Address:</dt>
<dd><?php $this->eprint($U['Mailing Address']) ?><br />
<?php $this->eprint($U['City'] . ', ' . $U['State'] . ' ' . $U['Zip'])?></dd>
<dt>E-mail:</dt>
<dd><?php $this->eprint($U['Email Address']) ?></dd>
<dt>Affiliation:</dt>
<dd><?php $this->eprint($U['Affiliation']) ?></dd>
<dt>Phone Number:</dt>
<dd><?php $this->eprint($U['Phone Number']) ?></dd>
</dl>

</div>

<div id="content">

<noscript><div id="no-js">You must have Javascript enabled in your Web browser to use the Project CREATE site.</div></noscript>

<h1>Project CREATE</h1>

<?php if ($this->has_ordered): ?>
<p><strong>You have already ordered a poster.</strong><br />Please feel free to continue creating posters, but be aware that you may not order any more.</p>
<?php endif; ?>

<div class="big-buttons">
<div><a href="postermaker.php">Create a New Poster</a></div>
<?php if ($this->has_posters): ?>
<div><a href="reviewposters.php">Review Existing Posters</a></div>
<?php else: ?>
<div class="disabled"><span>Review Existing Posters</span></div>
<?php endif; ?>
<div><a href="changeuser.php">Change User Information</a></div>
<div><a href="login.php?logout=true">Logout</a></div>
</div>

</div>

<script type="text/javascript" src="js/jquery.swfobject.1-1-1.min.js"></script>
<script type="text/javascript">
$(document).ready(function() {
	if (!$.flash.available)
	{
		$("#content").prepend(
			'<div id="no-flash">'+
			'	<div class="get-flash"><a href="http://www.adobe.com/go/getflashplayer"><img src="images/160x41_Get_Flash_Player.jpg" alt="Get Adobe Flash Player"></a></div>'+
			'	<p>Adobe Flash is required to use the Project CREATE program.<br /><a href="http://www.adobe.com/go/getflashplayer">Click here to download it</a>.</p>'+
			'</div>'
		)
	}
});
</script>

<?php $this->display("footer.tpl.php"); ?>