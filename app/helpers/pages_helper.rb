module PagesHelper
  def link_to_next_page(scope, name, options = {}, &block)
    params = options.delete(:params) || {}
    param_name = options.delete(:param_name) || Kaminari.config.param_name
    link_to_unless scope.last_page?, name, params.merge(param_name => (scope.current_page + 1)), options.merge(:rel => 'next') do
      block.call if block
    end
  end
end
