module ApplicationHelper
  def active_link(url_path)
    "menu-active" if request.path.start_with?(url_path)
  end
end
