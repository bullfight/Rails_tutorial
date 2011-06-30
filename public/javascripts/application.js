$(document).ready(function() {

  // Micropost Class Additions
  $("div.feed-item:first, div.user-item:first").addClass("first");
  $("hr:last").addClass("last");
  
  
  // Micropost Count 
  $("textarea#micropost_content").keydown(function() {
    count_length(this);
  });
  $("textarea#micropost_content").keyup(function() {
    count_length(this);
  });
  
  function count_length(object) {
    $("#micropost_form .count").text((140 - object.value.length) + " characters remain");
    if(object.value.length > 140){
      $("#micropost_form .count").addClass("lengtherror");
    }else{
      $("#micropost_form .count").removeClass("lengtherror");
    };
  };
  
  
  // Micropost Delete 
  $("span.item-delete a").bind('ajax:success', function() {  
    $(this).closest("div.feed-item").animate({
      opacity: 'hide', 
      height: 'hide'}, 
      'slow'); 
  });
  
  
  // Micropost Hover 
  $("div#users div.user-item, div#microposts div.feed-item").hover(function(){
    $(this).toggleClass("highlight");
  });
  
  
  // Preview Micropost
  $("div#micropost_preview").hide();
  
  $("textarea#micropost_content").keydown(function() {
    preview(this);
  });
  
  $("textarea#micropost_content").keyup(function() {
    preview(this);
  });
  
  function preview(object){
    var content = object.value;
    
    if( content.length > 0 ){
      $("div#micropost_preview").slideDown();
    }else if( content.length = 1 ){
      $("div#micropost_preview").slideUp();
    };
      
    $("div#micropost_preview div.item-row div.item-content").text(
      content
     );    
  };
  
  // Micropost Formatting
  $("div#micropost_formatting").hide();
  $("div#micropost_form span.formatting a").click(function(e){
    e.preventDefault();
    $("div#micropost_formatting").slideToggle();    
  }).toggle(
    function(){
      $(this).text("(collapse formatting help)");
    }, function(){
      $(this).text("(expand formatting help)");
  });
  
});