# frozen_string_literal: true

class MapsController < ApplicationController
  def index
    @cases = Case.pluck(:id,
                              :latitude,
                              :longitude,
                              :avatar,
                              :title,
                              :overview)

    # Substitute avatar URL for empty object in 4th variable
    @cases.each do |article|
      article[3] = Case.find_by_id(article[0]).avatar.medium_avatar.to_s
    end
  end
end
