<?php $this->display("header.tpl.php") ?>

<div id="navcontainer">

</div>

<div id="content">  

	<h1>Server Error</h1>
<?php if ($this->error_msg): ?>
	<h3><?php $this->eprint($this->error_msg) ?></h3>
<?php endif; ?>

	<p>A server problem has prevented the request from being completed. Please report the problem to the Project CREATE team at <a href="mailto:rcap.create@gmail.com">rcap.create@gmail.com</a>.</p>

<?php if ($this->error_code): ?>
	<p>When you contact support, please include this error code: <?php $this->eprint($this->error_code) ?></p>
<?php endif; ?>

</div>

<?php $this->display("footer.tpl.php") ?>