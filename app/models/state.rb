class State < ActiveRecord::Base
	has_many :cases
  has_many :agencies
	searchkick
end
