//= require_directory ./libraries/
//= require_directory ./plugins/
//= require_self

$(document).ready(function() {
  $('.route_list').dataTable({
    "aaSorting": [], //[[ 1, "asc" ]],
    "bPaginate": false,
    "bJQueryUI": true,
    "aoColumns": [
      null, //name
      null, //verb
      null, //path
      null, //action
      null, //covered yes/no
      null, //hits count
    ]
  });

  // Make sure tabs don't get ugly focus borders when active
  $('.group_tabs a').on('focus', function() { $(this).blur(); });

  $('.group_tabs a').on('click', function(){
    if (!$(this).parent().hasClass('active')) {
      $('.group_tabs a').parent().removeClass('active');
      $(this).parent().addClass('active');
      $('.file_list_container').hide();
      $(".file_list_container" + $(this).attr('href')).show();
      window.location.hash = $(this).attr('href').replace('#', '#_');
    }
    return false;
  });

  $('.file_list_container').hide();
  // switch to previously selected tab on reload or first if none
  if (window.location.hash.substr(1)) {
    var anchor = window.location.hash.substr(1);
    $('.group_tabs a.'+anchor.replace('_', '')).click();
  } else {
    $('.group_tabs a:first').click();
  };

  $("abbr.timeago").timeago();
  $('#loading').fadeOut();
  $('#wrapper').show();
});
