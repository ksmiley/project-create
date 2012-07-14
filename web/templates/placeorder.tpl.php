<?php
$U = $this->user;
$P = $this->poster;
$this->display("header.tpl.php");
$this->display("leftnav.tpl.php");
?>

<div id="content">

<h1>Thank you for participating!</h1>

<div style="text-align:center;">
	<img src="<?php $this->eprint(IMAGE_PREVIEW_URL.'/'.$P['FilePath']) ?>" />
</div>

</div>

<?php $this->display("footer.tpl.php"); ?>