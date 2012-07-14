<?php
$U = $this->user;
$this->display("header.tpl.php");
$this->display("leftnav.tpl.php");
?>

<div id="content">

<h2>Change User Information</h2>

<div id="change-user-input" class="long-form">

<?php if ($this->msg): ?>
<div class="error-msg"><?php $this->eprint($this->msg); ?></div>
<?php endif; ?>
<?php if ($this->saved): ?>
<div class="saved-msg"><a href="index.php">Return to main menu.</a></div>
<?php endif; ?>

<?php if ($this->show_pass): ?>

<h3>Change Password</h3>

<form id="change-password-form" action="changeuser.php" method="POST">
<input type="hidden" name="act" value="changepass">

<label for="field-oldpass">Old Password:</label>
<input id="field-oldpass" type="password" name="oldpass" />

<label for="field-newpass1">New Password:</label>
<input id="field-newpass1" type="password" name="newpass1" />

<label for="field-newpass2">Repeat New Password:</label>
<input id="field-newpass2" type="password" name="newpass2" />

<div class="actions">
	<input type="submit" value="Change Password" /> or <a href="index.php">cancel</a>
</div>

<script type="text/javascript">
$(document).ready(function(){
	$("#change-password-form").submit(function(){
		var setError = function(msg){
			if ($("#change-user-input .error-msg").size() == 0)
			{
				$("#change-user-input").prepend('<div class="error-msg"/>');
			}
			$("#change-user-input .error-msg").text(msg);
		};
		if ($.trim($("#field-oldpass").val()) == "" || $.trim($("#field-newpass1").val()) == 0 || $.trim($("#field-newpass2").val()) == 0)
		{
			setError("To change your password, please fill in all three fields.");
		}
		else if ($("#field-newpass1").val() != $("#field-newpass2").val())
		{
			setError("New passwords do not match.");
		}
		else if ($("#field-newpass1").val().length < 5 || $("#field-newpass1").val().length > 20)
		{
			setError("Passwords must be at least 5 characters long and less than 20 characters. Password should contain a mix of letters, numbers, and symbols.");
		}
		else
		{
			return true;
		}
		return false;
	});
})
</script>

</form>

<?php endif; ?>
<?php if ($this->show_info): ?>

<h3>Change Contact Information</h3>

<form id="change-info-form" action="changeuser.php" method="POST">
<input type="hidden" name="act" value="changeinfo">

<label for="field-name">Name:</label>
<input id="field-name" type="text" name="Name" value="<?php $this->eprint($U['Name']) ?>" />

<label for="field-affiliation">Affiliation:</label>
<input id="field-affiliation" type="text" name="Affiliation" value="<?php $this->eprint($U['Affiliation']) ?>" />

<label for="field-address">Address:</label>
<input id="field-address" type="text" name="Address" value="<?php $this->eprint($U['Mailing Address']) ?>" />

<label for="field-city">City:</label>
<input id="field-city" type="text" name="City" value="<?php $this->eprint($U['City']) ?>" />

<label for="field-state">State:</label>
<input id="field-state" type="text" name="State" value="<?php $this->eprint($U['State']) ?>" />

<label for="field-zip">Zip:</label>
<input id="field-zip" type="text" name="Zip" value="<?php $this->eprint($U['Zip']) ?>" />

<label for="field-phone">Phone Number:</label>
<input id="field-phone" type="text" name="PhoneNumber" value="<?php $this->eprint($U['Phone Number']) ?>" />

<label for="field-email">E-mail Address:</label>
<input id="field-email" type="text" name="Email" value="<?php $this->eprint($U['Email Address']) ?>" />

<div class="actions">
	<input type="submit" value="Update" /> or <a href="index.php">cancel</a>
</div>

</form>

<?php endif; ?>

</div>

</div>

<?php $this->display("footer.tpl.php"); ?>