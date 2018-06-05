function togglePrivateTicketsOnChange() {
  var checked = $(this).is(':checked');
  $('.private_tikets').attr('disabled', !checked);
}

function togglePrivateTicketsInit() {
  $('.assign_contact_user').each(togglePrivateTicketsOnChange);
}

$(document).ready(function(){
  $('#content').on('change', '.assign_contact_user', togglePrivateTicketsOnChange);
  togglePrivateTicketsInit();

  $('#history .contextual a[title="Quote"]').click(function(){
    var journal_id = this.href.match(/journal_id=(\d*)/)[1];
    console.log(journal_id);
    $.ajax({
      method: 'GET',
      url: '/helpdesk/update_customer_email',
      data: { journal_id: journal_id }
   });
  });
});
