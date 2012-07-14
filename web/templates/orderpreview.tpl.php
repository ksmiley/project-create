<?php
$U = $this->user;
$P = $this->poster;
$this->display("header.tpl.php");
$this->display("leftnav.tpl.php");
?>

<div id="content">

<div id="poster-order-input" class="long-form">
<h2>Order Poster</h2>
<form action="placeorder.php" method="POST">
<input type="hidden" name="poster_id" value="<?php $this->eprint($P['id']) ?>" />

<label for="field-quantity">Quantity:</label>
<input id="field-quantity" type="text" name="Quantity" value="1" disabled="disabled" />

<label for="field-size">Poster Size:</label>
<input id="field-size" type="text" name="Poster Size" value="<?php $this->eprint($P['Poster Size']) ?>" disabled="disabled" />

<h3>Shipping Address</h3>

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
	<input type="submit" value="Place Order" /> or <a href="reviewposters.php">cancel</a>
</div>

</form>
</div>

<div id="poster-order-preview">
	<img src="<?php $this->eprint(IMAGE_PREVIEW_URL.'/'.$P['FilePath']) ?>" />
</div>

</div>

<?php $this->display("footer.tpl.php"); ?>