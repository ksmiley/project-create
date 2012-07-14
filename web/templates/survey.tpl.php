<?php
$U = $this->user;
$this->display("header.tpl.php") 
?>

<iframe frameborder="0" src="https://uky.qualtrics.com/SE?SID=SV_4Zr2GhVkjFfv74o&amp;PosterID=<?php echo urlencode($this->poster_id) ?>&amp;UserID=<?php echo urlencode($U['id']) ?>" width="980" height="500">
<a target="_blank" title="Survey Software" href="http://www.qualtrics.com/survey-software/">Survey Software</a><br/><a target="_blank" title="Enterprise Feedback Management" href="http://www.qualtrics.com/solutions/enterprise-feedback-management/">Enterprise Feedback Management</a><br/>
<a target="_blank" href="https://uky.qualtrics.com/SE?SID=SV_4Zr2GhVkjFfv74o">Please click on this link to take the survey</a><br/>
</iframe>

<?php $this->display("footer.tpl.php") ?>