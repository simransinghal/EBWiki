require 'rails_helper'

describe Case, :versioning => true do
  it "is invalid without a date" do
    this_case =  build(:case, date: nil)
    expect(this_case).to be_invalid
  end

  it "is invalid without a state_id" do
    this_case =  build(:case, state_id: nil)
    expect(this_case).to be_invalid
  end

  it 'is invalid without a subject' do
    this_case =  create(:case)
    this_case.subjects = []
    expect(this_case).to be_invalid
  end

  it "is invalid without a summary" do
    this_case =  build(:case, summary: nil)
    expect(this_case).to be_invalid
  end

  it 'starts versioning when a new article is created' do
    this_case =  FactoryGirl.create(:case)
    expect(this_case.versions.size).to eq 1
    expect(this_case.versions[0].event).to eq 'create'
  end
  it 'adds a version when the title is changed' do
    this_case =  FactoryGirl.create(:case)
    this_case.update_attribute(:title, "A New Title")
    expect(this_case.versions.size).to eq 2
  end
  it 'adds a version when the overview is changed' do
    this_case =  FactoryGirl.create(:case)
    this_case.update_attribute(:overview, "An Old Case")
    expect(this_case.versions.size).to eq 2
  end
  it 'adds a version when the date is changed' do
    this_case =  FactoryGirl.create(:case)
    this_case.update_attribute(:date, Date.yesterday)
    expect(this_case.versions.size).to eq 2
  end
  it 'adds a version when the city is changed' do
    this_case =  FactoryGirl.create(:case)
    this_case.update_attribute(:city, "New Jack City")
    expect(this_case.versions.size).to eq 2
  end
  it 'adds a version when the avatar is changed' do
    this_case =  FactoryGirl.create(:case)
    this_case.update_attribute(:avatar, "new_avatar")
    expect(this_case.versions.size).to eq 2
  end
  it 'adds a version when the video url is changed' do
    this_case =  FactoryGirl.create(:case)
    this_case.update_attribute(:video_url, "new_video.com")
    expect(this_case.versions.size).to eq 2
  end
  it 'adds a version when the slug is changed' do
    this_case =  FactoryGirl.create(:case)
    this_case.update_attribute(:slug, "joel-osteen")
    expect(this_case.versions.size).to eq 2
  end
  it 'does not add a version when the attribute is the same' do
    this_case =  FactoryGirl.create(:case, title: "The Title")
    this_case.update_attributes(:title, "The Title")
    expect(this_case.versions.size).to eq 1
  end
  it 'copies the article.summary attribute to version.comment' do
    this_case =  FactoryGirl.create(:case, title: "The Title")
    this_case.update_attributes(:title => "The Title has changed", :summary => "fixed the title")
    expect(this_case.versions.last.comment).to eq "fixed the title"
  end

  it 'adds city to slug to maintain uniqueness' do
    this_case =  FactoryGirl.create(:case, title: "The Title")
    that_case =   FactoryGirl.create(:case, title: "The Title")
    expect(this_case2.slug).to eq "the-title-albany"
  end

  it 'updates slug if article title is updated' do
    this_case =  FactoryGirl.create(:case, title: "The Title")
    this_case.slug = nil
    this_case.title = "Another Title"
    this_case.save!
    this_case.reload
    expect(this_case.slug).to eq "another-title"
  end

end

describe "#new" do
  it "takes three parameters and returns an Case object" do
  this_case =  build(:case)
    expect(this_case).to be_an_instance_of Case
  end
end

describe "#title" do
  it "returns the correct title" do
    this_case =  build(:case)
      expect(this_case.title).to include "Title"
  end
end

describe "follower_count" do
  it "gives the correct followers count" do
    this_case =  FactoryGirl.create(:case, id: 10)
    FactoryGirl.create(:follow, followable_id: 10)
    expect(this_case.followers.count).to eq(1)
  end
  it "has a zero counter cache to start" do
    this_case =  FactoryGirl.create(:case)
    expect(Case.last.follows_count).to eq(0)
  end
  it "has a counter cache" do
    this_case =  FactoryGirl.create(:case)
    expect {
      article.follows.create(follower_id: 1, followable_id: article.id, followable_type: "Case", follower_type: "User")
    }.to change { article.reload.follows_count }.by(1)
  end
end

describe "#content" do
  it "returns the correct content" do
    this_case =  build(:case)
      expect(this_case.overview).to eq "A new article"
  end
end

describe "geocoded" do
  it "has a latitude" do
    this_case =  FactoryGirl.create(:case)
      expect(this_case.latitude).not_to be_nil
  end
  it "has a longitude" do
    this_case =  FactoryGirl.create(:case)
      expect(this_case.longitude).not_to be_nil
  end
end

describe "#nearby_cases" do
  describe "on success" do
    it "returns an empty array if no cases are nearby" do
      this_case =  FactoryGirl.create(:case)
      expect(this_case.nearby_cases).to be_empty
    end
  end
  describe "on failure" do
    it "does not raise an error if the nearbys method returns nil" do
      this_case =  FactoryGirl.create(:case)
      allow(article).to receive(:nearbys).and_return(nil)
      expect{article.nearby_cases}.not_to raise_error
    end
  end
end

describe "recently updated cases" do
  it "returns only cases updated in past 30 days" do
    this_case =  FactoryGirl.create(:case, updated_at: 31.days.ago)
    that_case =   FactoryGirl.create(:case)
    article2.update_attribute(:video_url, "new_video.com")
    expect(Case.first.cases_updated_last_30_days).to eq(1)
  end
end

describe "growth_in_case_updates" do
  it "returns correct percentage increase" do
    this_case =  FactoryGirl.create(:case, updated_at: 31.days.ago)
    that_case =  FactoryGirl.create(:case)
    the_third_case =   FactoryGirl.create(:case, updated_at: 10.days.ago)
    article2.update_attribute(:video_url, "new_video.com")
    expect(Case.first.mom_growth_in_case_updates).to eq(100)
  end
end

describe "recent case growth rate" do
  it "returns the correct percentage increase" do
    this_case =  FactoryGirl.create(:case, date: 31.days.ago)
    that_case =   FactoryGirl.create(:case)
    expect(Case.first.mom_new_cases_growth).to eq(0)
  end
end

describe "total case growth rate" do
  it "returns the correct percentage increase" do
    this_case =  FactoryGirl.create(:case, created_at: 31.days.ago)
    that_case =   FactoryGirl.create(:case)
    expect(Case.first.mom_cases_growth).to eq(100)
  end
end