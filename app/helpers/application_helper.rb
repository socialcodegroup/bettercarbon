# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def javascript_includes
    files = [
              'jquery', 'jquery-ui', 'jrails', 'js-class', 'excanvas',
              'bluff-min', 'swfobject', 'raphael-min', 'g.raphael/g.raphael-min',
              'g.raphael/g.pie-min', 'g.raphael/g.bar', 'application', 'flot/jquery.flot.min',
              'flot/jquery.flot.pie', 'jit-yc'
            ]
    javascript_include_tag(files, :cache => "_javascript")
  end
  
  def stylesheet_includes
    stylesheet_link_tag('reset', 'layout', :cache => "_stylesheet")
  end
  
  def facebook_javascript_includes
    javascript_tag output_js_files_content("jit-yc.js")
  end
  
  def facebook_stylesheet_includes
    stylesheet_link_tag('fb_layout', :cache => "_fb_stylesheet")
  end
end
