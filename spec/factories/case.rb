# frozen_string_literal: true

# This will guess the Case class
FactoryBot.define do
  factory :case do |f|
    f.sequence(:title) { |n| "#{n}Title" }
    f.overview 'A new case'
    f.city 'Albany'
    f.date Date.today
    f.state
    f.subjects { [create(:subject)] }
    f.summary 'A summary of changes'
  end

  factory :invalid_case, class: Case do |f|
    f.title ''
    f.overview ''
    f.city ''
    f.date ''
  end
end
