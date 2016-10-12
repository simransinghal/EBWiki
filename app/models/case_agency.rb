class CaseAgency < ActiveRecord::Base
  belongs_to :case
  belongs_to :agency
end
