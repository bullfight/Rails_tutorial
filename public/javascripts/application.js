$(document).ready(function() {

  $("textarea#micropost_content").keydown(function() {
    $("#micropost_form .count").text((140 - this.value.length) + " characters remain");
    if(this.value.length > 140){
      $("#micropost_form .count").addClass("lengtherror");
    }else{
      $("#micropost_form .count").removeClass("lengtherror");
    };
  });
  $("textarea#micropost_content").keyup(function() {
    $("#micropost_form .count").text((140 - this.value.length) + " characters remain");
    if(this.value.length > 140){
      $("#micropost_form .count").addClass("lengtherror");
    }else{
      $("#micropost_form .count").removeClass("lengtherror");
    };
  });
  
});
