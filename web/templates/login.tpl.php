<?php $this->display("header.tpl.php") ?>

<div id="navcontainer">
<form action="login.php" method="POST">
<?php if ($this->error_msg): ?>
	<p class="form-error"><?php $this->eprint($this->error_msg) ?></p>
<?php endif; ?>
	<p>To get started with Project CREATE, please login:</p>
	<label for="login-user">Username</label>
	<input type="text" name="User" id="login-user" />
	<label for="login-pass">Password</label>
	<input type="password" name="Pass" id="login-pass" />
	<input type="hidden" name="return" value="<?php $this->eprint($this->return_url) ?>" />
	<input type="submit" name="login" value="Login" />
</form>
</div>

<div id="content" class="loginpage"> 

	<noscript><div id="no-js">You must have Javascript enabled in your Web browser to use the Project CREATE site.</div></noscript>

	<h1 style="margin:12px 0;">Welcome to Project CREATE</h1>
	
	<h3 style="margin:12px 0 20px;font-weight:normal;font-size:1.3em;color:#555;">&ldquo;create rural education AIDS tailoring effort.&rdquo;</h3>

	<p>A web-based tool for developing HIV/STD prevention materials for rural communities.</p>  

	<p><strong>Thank you for participating in an evaluation of the Project CREATE website. Please login to begin.</strong></p>

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

<?php $this->display("footer.tpl.php") ?>