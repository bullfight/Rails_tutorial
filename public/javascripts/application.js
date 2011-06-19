$(document).ready(function() {

  $("textarea#micropost_content").keydown(function() {
    $("span.count").text( "[" + (140 - this.value.length) + "] characters" );
  });
  $("textarea#micropost_content").keyup(function() {
    $("span.count").text( "[" + (140 - this.value.length) + "] characters" );
  });
  
});
