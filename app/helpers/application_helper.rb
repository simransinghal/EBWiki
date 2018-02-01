# frozen_string_literal: true

module ApplicationHelper
  def active_page(active_page)
    @active == active_page ? 'active' : ''
  end

  def avatar_url(user, size)
    default_url = "#{root_url}default-user-icon.png"
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end

  def filter
    if params[:controller] == 'maps'
      '/maps/index'
    else
      'cases'
    end
  end

  def marker_locations_for(cases)
    return nil if cases.blank?
    @hash = Gmaps4rails.build_markers(cases) do |this_case, marker|
      marker.lat this_case[1]
      marker.lng this_case[2]
      marker.infowindow controller.render_to_string(partial: '/cases/info_window', locals: { this_case: this_case })
    end
    @hash
  end
end
