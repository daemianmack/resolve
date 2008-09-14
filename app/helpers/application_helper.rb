# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def render_flash_message(css_class, message) 
    return "" if message.nil? or message.blank?
    content_tag( "div", message, :id => "flash_#{css_class}", :class => 'flash' )
  end
end
