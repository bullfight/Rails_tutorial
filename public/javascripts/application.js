$(document).ready(function() {

  // Micropost Class Additions
  $("div.feed-item:first, div.user-item:first").addClass("first");
  $("hr:last").addClass("last");
  
  
  // Events on Micropost Textarea
  $("textarea#micropost_content").bind('keydown keyup cut copy paste click focus', 
    function() {
      count_length(this);
      preview(this);
  });
    
  // Micropost Count
  function count_length(object) {
    $("#micropost_form span.count").text((140 - object.value.length) + " characters remain");
    if(object.value.length > 140){
      $("#micropost_form span.count").addClass("lengtherror");
    }else{
      $("#micropost_form span.count").removeClass("lengtherror");
    };
  };
  
  // Preview Micropost in Markdown
  $("div#micropost_preview").hide();
  function preview(object){
    var content = object.value;
    converter = new Showdown.converter();
    mkd = converter.makeHtml(content);
    
    if( content.length > 0 ){
      $("div#micropost_preview").slideDown();
    }else if( content.length = 1 ){
      $("div#micropost_preview").slideUp();
    };
      
    $("div#micropost_preview div.item-row div.item-content").html(
      mkd
     );    
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
    
  // Micropost Formatting Help
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
  
  // Insert Micropost Formatting      
  $('div#micropost_form span.insert_syntax a[href$="bold"]').click(function(e){
    e.preventDefault();    
    $("textarea#micropost_content").text(function(){
      insert_syntax(this, "**bold**", 2, 6);
    });
        
  });
  
  $('div#micropost_form span.insert_syntax a[href$="italics"]').click(function(e){
    e.preventDefault();
    $("textarea#micropost_content").text(function(){
      insert_syntax(this, "*italics*", 1, 8);
    });
  });
  
  $('div#micropost_form span.insert_syntax a[href$="link"]').click(function(e){
    e.preventDefault();
    $("textarea#micropost_content").text(function(){
      insert_syntax(this, "[link](www.link.com)", 7, 19);
    });
  });
  
  $('div#micropost_form span.insert_syntax a[href$="quote"]').click(function(e){
    e.preventDefault();
    $("textarea#micropost_content").text(function(){
      
      if( this.value.length == 0 ) {
        insert_syntax(this, "> quote \n", 2, 7);
      }else{
        insert_syntax(this, "\n > quote \n", 4, 9);
      };      
    });
  });
  
  $('div#micropost_form span.insert_syntax a[href$="list"]').click(function(e){
    e.preventDefault();
    $("textarea#micropost_content").text(function(){
      
      if( this.value.length == 0 ) {
        insert_syntax(this, "* list item 1\n* list item 2", 2, 13);
      }else{
        insert_syntax(this, "\n* list item 1\n* list item 2\n", 3, 14);
      };
      
    });
  });
  
  $('div#micropost_form span.insert_syntax a[href$="code"]').click(function(e){
    e.preventDefault();
    $("textarea#micropost_content").text(function(){
      
      if( this.value.length == 0 ) {
        insert_syntax(this, "```ruby\nputs 'hello world'\n```", 4, 8);
      }else{
        insert_syntax(this, "\n\n```ruby\nputs 'hello world'\n```", 5, 9);
      };
      
    });
  });
  
  function insert_syntax(obj, syntax, pos1, pos2){
    content = obj.value;
    cursorpos = $(obj).caret().start;
    content[cursorpos]
    
    content = content.substr(0,cursorpos) + 
      syntax + content.substr(cursorpos,content.count)
    
    obj.value = content
    $(obj).selectRange(cursorpos + pos1, cursorpos + pos2);
  };
    
  $.fn.selectRange = function(start, end) {
    return this.each(function() {
      if (this.setSelectionRange) {
        this.focus();
        this.setSelectionRange(start, end);
      } else if (this.createTextRange) {
        var range = this.createTextRange();
        range.collapse(true);
        range.moveEnd('character', end);
        range.moveStart('character', start);
        range.select();
      }
    });
  };
  
  
});