# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article, type: :model, versioning: true do

  describe "validity" do
    it 'is invalid without a date' do
      article = build(:article, date: nil)
      expect(article).to be_invalid
    end

    it 'is invalid without a state_id' do
      article = build(:article, state_id: nil)
      expect(article).to be_invalid
    end

    it 'is invalid without a subject' do
      article = create(:article)
      article.subjects = []
      expect(article).to be_invalid
    end

    it 'is invalid without a summary' do
      article = build(:article, summary: nil)
      expect(article).to be_invalid
    end
  end

  describe "versioning" do
    it 'starts versioning when a new article is created' do
      article = FactoryBot.create(:article)
      expect(article.versions.size).to eq 1
      expect(article.versions[0].event).to eq 'create'
    end

    it 'adds a version when the title is changed' do
      article = FactoryBot.create(:article)
      article.update_attribute(:title, 'A New Title')
      expect(article.versions.size).to eq 2
    end

    it 'adds a version when the overview is changed' do
      article = FactoryBot.create(:article)
      article.update_attribute(:overview, 'An Old Article')
      expect(article.versions.size).to eq 2
    end

    it 'adds a version when the date is changed' do
      article = FactoryBot.create(:article)
      article.update_attribute(:date, Date.yesterday)
      expect(article.versions.size).to eq 2
    end

    it 'adds a version when the city is changed' do
      article = FactoryBot.create(:article)
      article.update_attribute(:city, 'Buffalo')
      expect(article.versions.size).to eq 2
    end

    it 'adds a version when the avatar is changed' do
      article = FactoryBot.create(:article)
      article.update_attribute(:avatar, 'new_avatar')
      expect(article.versions.size).to eq 2
    end

    it 'adds a version when the video url is changed' do
      article = FactoryBot.create(:article)
      article.update_attribute(:video_url, 'new_video.com')
      expect(article.versions.size).to eq 2
    end

    it 'adds a version when the slug is changed' do
      article = FactoryBot.create(:article)
      article.update_attribute(:slug, 'joel-osteen')
      expect(article.versions.size).to eq 2
    end

    it 'does not add a version when the attribute is the same' do
      article = FactoryBot.create(:article, title: 'The Title')
      article.update_attribute(:title, 'The Title')
      expect(article.versions.size).to eq 1
    end

    it 'copies the article.summary attribute to version.comment' do
      article = FactoryBot.create(:article, title: 'The Title')
      article.update_attributes(title: 'The Title has changed', summary: 'fixed the title')
      expect(article.versions.last.comment).to eq 'fixed the title'
    end
  end

  describe "slugs" do
    it 'adds city to slug to maintain uniqueness' do
      article = FactoryBot.create(:article, title: 'The Title')
      article2 = FactoryBot.create(:article, title: 'The Title')
      expect(article2.slug).to eq 'the-title-albany'
      expect(article.slug).not_to eq article2.slug
    end

    it 'updates slug if article title is updated' do
      article = FactoryBot.create(:article, title: 'The Title')
      article.slug = nil
      article.title = 'Another Title'
      article.save!
      article.reload
      expect(article.slug).to eq 'another-title'
    end
  end

  describe '#new' do
    it 'takes three parameters and returns an Article object' do
      article = build(:article)
      expect(article).to be_an_instance_of Article
    end
  end

  describe '#title' do
    it 'returns the correct title' do
      article = build(:article)
      expect(article.title).to include 'Title'
    end
  end

  describe 'follower_count' do
    it 'gives the correct followers count' do
      article = FactoryBot.create(:article, id: 10)
      FactoryBot.create(:follow, followable_id: 10)
      expect(article.followers.count).to eq(1)
    end

    it 'has a zero counter cache to start' do
      article = FactoryBot.create(:article)
      expect(Article.last.follows_count).to eq(0)
    end

    it 'has a counter cache' do
      article = FactoryBot.create(:article)
      expect do
        article.follows.create(follower_id: 1, followable_id: article.id, followable_type: 'Article', follower_type: 'User')
      end.to change { article.reload.follows_count }.by(1)
    end
  end

  describe '#content' do
    it 'returns the correct content' do
      article = build(:article)
      expect(article.overview).to eq 'A new article'
    end
  end

  describe 'geocoded' do
    it 'generates longitude and latitude from city and state on save' do
      article = FactoryBot.create(:article)
      expect(article.latitude).to be_a(Float)
      expect(article.longitude).to be_a(Float)
    end

    it 'updates geocoded coordinates when relevant fields are updated' do
      article = FactoryBot.create(:article)
      ohio = FactoryBot.create(:state_ohio)

      expect do
        article.update_attributes(city: 'Worthington',
                                  state_id: ohio.id,
                                  address: '1867 Irving Road',
                                  zipcode: '43085')
      end.to change { article.latitude }
    end
  end

  describe '#nearby_cases' do
    it 'returns an empty array if no cases are nearby' do
      article = FactoryBot.create(:article)
      expect(article.nearby_cases).to be_empty
    end

    it 'does not raise an error if the nearbys method returns nil' do
      article = FactoryBot.create(:article)
      allow(article).to receive(:nearbys).and_return(nil)
      expect { article.nearby_cases }.not_to raise_error
    end
  end

  describe 'recently updated cases' do
    it 'returns only cases updated in past 30 days' do
      article = FactoryBot.create(:article, updated_at: 31.days.ago)
      article2 = FactoryBot.create(:article)
      article2.update_attribute(:video_url, 'new_video.com')
      expect(Article.first.cases_updated_last_30_days).to eq(1)
    end
  end

  describe 'growth' do
    describe 'growth_in_case_updates' do
      it 'returns the correct percentage increase' do
        article = FactoryBot.create(:article, updated_at: 31.days.ago)
        article2 = FactoryBot.create(:article)
        article3 = FactoryBot.create(:article, updated_at: 10.days.ago)
        article2.update_attribute(:video_url, 'new_video.com')
        expect(Article.first.mom_growth_in_case_updates).to eq(100)
      end

      it 'returns 0 if no updates in last 30 days' do
        article = FactoryBot.create(:article, updated_at: 31.days.ago)
        expect(Article.first.mom_growth_in_case_updates).to eq(0)
      end

      # What happens if there were updates between 0-30 days ago but none 31-60 days ago?
      it 'returns correct percentage if previous 30 days period saw no updates' do
        article = FactoryBot.create(:article, updated_at: 10.days.ago)
        expect(Article.first.mom_growth_in_case_updates).to eq(100)
      end
    end

    describe 'new case growth rate' do
      it 'returns the correct percentage increase' do
        article = FactoryBot.create(:article, date: 31.days.ago)
        article2 = FactoryBot.create(:article)
        expect(Article.first.mom_new_cases_growth).to eq(0)
      end

      it 'returns 0 if no new cases in last 30 days' do
        article = FactoryBot.create(:article, date: 31.days.ago)
        expect(Article.first.mom_new_cases_growth).to eq(0)
      end

      # What happens if there were new cases between 0-30 days ago but none 31-60 days ago?
      it 'returns correct percentage if previous 30 days period saw no new cases' do
        article_one = FactoryBot.create(:article, date: 10.days.ago)
        article_two = FactoryBot.create(:article, date: 15.days.ago)
        expect(Article.first.mom_new_cases_growth).to eq(200)
      end
    end

    describe 'total case growth rate' do
      it 'returns the correct percentage increase' do
        article = FactoryBot.create(:article, created_at: 31.days.ago)
        article2 = FactoryBot.create(:article)
        expect(Article.first.mom_cases_growth).to eq(100)
      end

      it 'returns 0 if no created cases in last 30 days' do
        article = FactoryBot.create(:article, created_at: 31.days.ago)
        expect(Article.first.mom_cases_growth).to eq(0)
      end

      #What happens if all of the cases were created in the past 30 days?
      it 'returns correct percentage if all cases created in the past 30 days' do
        article_one = FactoryBot.create(:article, date: 10.days.ago)
        article_two = FactoryBot.create(:article, date: 15.days.ago)
        expect(Article.first.mom_cases_growth).to eq(200)
      end
    end

  end

  describe '#default_avatar_url' do
    it 'takes the avatar''s default URL and turns this into a column' do
      article = FactoryBot.create(:article)
      avatar_mock = double('Avatar', url: 'https://avatar.com')
      allow(article).to receive(:default_avatar_url).and_return(avatar_mock.url)
      expect(article.default_avatar_url).to_not be_nil
    end
  end

  describe 'scopes' do

    it 'returns articles based on case' do
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_article = FactoryBot.create(:article,
                                       city: 'Houston',
                                       state_id: texas.id)
      louisiana_article = FactoryBot.create(:article,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id)

      sorted_articles = Article.by_state texas.id
      expect(sorted_articles.count).to eq 1
      expect(sorted_articles.to_a).not_to include louisiana_article
    end

    it 'returns articles created in the past month' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_article = FactoryBot.create(:article,
                                       city: 'Houston',
                                       state_id: texas.id,
                                       created_at: Time.current)
      louisiana_article = FactoryBot.create(:article,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id,
                                            created_at: 5.weeks.ago)
      dc_article = FactoryBot.create(:article,
                                     city: 'Washington',
                                     state_id: dc.id,
                                     created_at: 1.year.ago)

      recent_article = Article.created_this_month
      expect(recent_article.count).to eq 1
      expect(recent_article.to_a).not_to include(louisiana_article)
      expect(recent_article.to_a).not_to include(dc_article)
    end

    it 'returns the most recently occurring cases' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_article = FactoryBot.create(:article,
                                        city: 'Houston',
                                        state_id: texas.id,
                                        date: Time.current)
      louisiana_article = FactoryBot.create(:article,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id,
                                            date: 2.weeks.ago)
      dc_article = FactoryBot.create(:article,
                                     city: 'Washington',
                                     state_id: dc.id,
                                     date: 1.year.ago)

      recent_articles = Article.most_recent_occurrences 1.month.ago
      expect(recent_articles.count).to eq 2
      expect(recent_articles.to_a).not_to include(dc_article)
    end

    it 'returns the most recently updated cases' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_article = FactoryBot.create(:article,
                                        city: 'Houston',
                                        state_id: texas.id,
                                        updated_at: Time.current)
      louisiana_article = FactoryBot.create(:article,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id,
                                            updated_at: 2.weeks.ago)
      dc_article = FactoryBot.create(:article,
                                     city: 'Washington',
                                     state_id: dc.id,
                                     updated_at: 1.year.ago)

      recent_articles = Article.recently_updated 1.month.ago
      expect(recent_articles.count).to eq 2
      expect(recent_articles.to_a).not_to include(dc_article)
    end

    it 'returns cases sorted by update date' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_article = FactoryBot.create(:article,
                                        city: 'Houston',
                                        state_id: texas.id,
                                        updated_at: Time.current)
      louisiana_article = FactoryBot.create(:article,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id,
                                            updated_at: 2.weeks.ago)
      dc_article = FactoryBot.create(:article,
                                     city: 'Washington',
                                     state_id: dc.id,
                                     updated_at: 1.year.ago)

      sorted_articles = Article.sorted_by_update 2
      expect(sorted_articles.count).to eq 2
      expect(sorted_articles.to_a).not_to include(dc_article)
    end

    it 'returns cases sorted by number of followers' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_article = FactoryBot.create(:article,
                                        city: 'Houston',
                                        state_id: texas.id,
                                        updated_at: Time.current)
      louisiana_article = FactoryBot.create(:article,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id,
                                            updated_at: 2.weeks.ago)
      dc_article = FactoryBot.create(:article,
                                     city: 'Washington',
                                     state_id: dc.id,
                                     updated_at: 1.year.ago)

      follow_one = FactoryBot.create(:follow, followable_id: texas_article.id)
      follow_two = FactoryBot.create(:follow, followable_id: texas_article.id)
      follow_three = FactoryBot.create(:follow, followable_id: dc_article.id)
      follow_four = FactoryBot.create(:follow, followable_id: dc_article.id)
      follow_five = FactoryBot.create(:follow, followable_id: louisiana_article.id)

      sorted_articles = Article.sorted_by_followers 2
      expect(sorted_articles.count).to eq 2
      expect(sorted_articles.to_a).not_to include(louisiana_article)
    end
  end
end
