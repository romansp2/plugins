$(document).ready(function(){
  //$( "#relation_email_with_project" ).button();
  //$("#back").button();
});

//Can't use Rails' remote select because we need the form data
function updateHotButtonForm(url) {
  $.ajax({
    url: url,
    type: 'post',
    data: $('#hot-buttons-form').serialize()
  });
}
