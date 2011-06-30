module MicropostsHelper
  
  def markdown(text, max_width = 30)
    options = [:hard_wrap, :filter_html, :autolink, 
              :no_intraemphasis, :fenced_code, :gh_blockcode, :tables]
    #text = wrap(text, max_width)
    Redcarpet.new(text, *options).to_html.html_safe
  end
  
  def wrap(text, max_width)
    sanitize(raw(text.split.map{ |s| wrap_long_string(s, max_width) }.join(' ')))
  end

  private

    def wrap_long_string(text, max_width)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text : 
                                  text.scan(regex).join(zero_width_space)
    end
end