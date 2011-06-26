module ApplicationHelper  
  # Return a title on a per-page basis.
    def titled
      base_title = "Feed Me"
      if @title.nil?
        base_title
      else
        "#{base_title} | #{@title}"
      end
    end
    
    def logo
      image_tag( "rails.png", :alt => "Sample App", :class => "round")      
    end
end
