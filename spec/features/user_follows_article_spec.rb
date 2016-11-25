require 'rails_helper'

feature "User follows an article from show" do
	let(:case) { FactoryGirl.create(:case) }
	scenario "User arrives at the article show page and clicks to follow" do
	  article.state = FactoryGirl.create(:state)
		user = FactoryGirl.create(:user)
		login_as(user, :scope => :user)
		visit article_path(article)
		click_link 'Follow'
		expect(article.followers.count).to eq(1)
	end

	scenario "User arrives at the article show page and clicks to unfollow" do
	  article.state = FactoryGirl.create(:state)
		user = FactoryGirl.create(:user)
		login_as(user, :scope => :user)
		visit article_path(article)
		click_link 'Follow'
		click_link 'Unfollow'
		expect(article.followers.count).to eq(0)
	end
end

feature "Non-logged in user attempts to follow an article from show" do
	let(:case) { FactoryGirl.create(:case) }
	scenario "User arrives at the article show page and clicks to follow" do
	  article.state = FactoryGirl.create(:state)
		visit article_path(article)
		click_link 'Follow'
		expect(current_path).to eq("/users/sign_in")
	end
end