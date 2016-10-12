FactoryGirl.define do

  factory :case do |f|
    f.sequence(:title) {|n| "#{n}Title"}
    f.overview "A new case"
    f.city "Albany"
    f.date Date.today
    f.state_id 33
    f.subjects { [ create(:subject)] }
    f.summary "A summary of changes"
  end

  factory :invalid_case, class: Case do |f|
    f.title ""
    f.overview ""
    f.city ""
    f.date ""
    # association :state, name: nil
  end

end