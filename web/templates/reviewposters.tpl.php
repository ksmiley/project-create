<?php
$U = $this->user;
$this->display("header.tpl.php");
$this->display("leftnav.tpl.php");
?>

<link rel="stylesheet" href="css/fancybox/jquery.fancybox-1.3.2.css" type="text/css" media="screen" />
<script type="text/javascript" src="js/jquery.fancybox-1.3.2.pack.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$("#poster-preview-sheet a").fancybox({
			titlePosition: 'inside',
			titleFormat: function(title, currentArray, currentIndex, currentOpts) {
				var target = currentArray.eq(currentIndex).parent();
				var infoDiv = target.find(".poster-info").clone().show();
<?php if ($this->can_order): ?>
				var button = $('<input type="submit" class="poster-select-button" value="Order This Poster" />').prependTo(infoDiv);
				button.click(function() {
					$("#poster-preview-sheet div.selected").removeClass("selected");
					target.addClass("selected");
					$.fancybox.close();
					$("html, body").animate({scrollTop: 0}, 'slow');
					$("#start-order-button").removeAttr("disabled");
					$("#poster-order-bar p").text("You have selected a poster to order. Click the button to the right to continue.");
					$("#poster-order-bar form input[name=poster_id]").val( target.find("img").attr("alt") );
				});
<?php endif; ?>
				return infoDiv;
			}
		});
	});
	/* Work around an IE8 bug that causes horizontal images to overflow */
	/* their containers when they have a max-width and are inside a */ 
	/* display:table-cell block. IE7 didn't have the problem. It appears */
	/* IE8 calculates the new image size correctly, but then flows the */
	/* element based on the original image width. Manually setting the */
	/* width to the calculated value makes the images pop back into place. */
	/*@cc_on
	@if (@_jscript_version == 5.8)
		$(window).load(function() {
			$("#poster-preview-sheet div a img").each(function() {
				$(this).css("width", $(this).width() + "px");
			});
		});
	@end
	@*/
</script>

<!-- Work around IE6/7 not supporting display:table-cell -->
<!--[if lt IE 8]>
<style>
#poster-preview-sheet div a * {
	vertical-align: middle;
}
#poster-preview-sheet div a span {
	display: inline-block;
	height: 100%;
}
</style>
<script>
$(document).ready(function(){
	$("#poster-preview-sheet div a").prepend("<span></span>");
});
</script>
<![endif]-->
<!-- Work around IE6 not supporting max-width/max-height -->
<!--[if IE 6]>
<script>
$(window).load(function() {
	$("#poster-preview-sheet div a img").each(function(){
		var t = $(this);
		if (t.width()> t.height())
		{
			if (t.width() > 200) { t.width(200); }
		}
		else
		{
			if (t.height() > 200) { t.height(200); }
		}
		t.show();
	});
});
</script>
<![endif]-->

<div id="content">

<noscript><div id="no-js">You must have Javascript enabled in your Web browser to use the Project CREATE site.</div></noscript>

<?php if (count($this->posters) > 0): ?>

<h1>Posters You Created</h1>

<?php if ($this->can_order): ?>

<div id="poster-order-bar">
<p>Click a poster below to view it. You can order one of the posters now, 
or <a href="postermaker.php">create a new poster</a> and order later.</p>
<form action="orderpreview.php" method="POST">
<input type="hidden" name="poster_id" value="" />
<input type="submit" id="start-order-button" value="Continue with Order" disabled="disabled" />
</form>
</div>

<?php else: ?>

<p>You have already placed an order, but you can still click the images below to see larger versions of the posters you created.</p>

<?php endif; ?>

<div id="poster-preview-sheet">
<?php foreach ($this->posters as $P): ?>
	<div>
		<a href="<?php $this->eprint(IMAGE_PREVIEW_URL.'/'.$P['FilePath']) ?>" rel="poster">
			<img alt="<?php $this->eprint($P['id']) ?>" src="<?php $this->eprint(IMAGE_PREVIEW_URL.'/'.$P['FilePath']) ?>" />
		</a>
		<div class="poster-info" style="display:none;">
			<p>Target Audience: <?php echo translate_groupname($P['Target Group 1'])?>, <?php echo translate_groupname($P['Target Group 2'])?>, <?php echo translate_groupname($P['Target Group 3'])?></p>
			<p>Poster created <?php echo $P['Creation Date'] ?></p>
		</div>
	</div>
<?php endforeach; ?>
</div>

<?php else: ?>
	<h2>No posters to review</h2>
	<p>You have not yet created any posters. <a href="postermaker.php">Click here to start creating posters</a>.
<?php endif; ?>

</div>

<?php $this->display("footer.tpl.php"); ?>