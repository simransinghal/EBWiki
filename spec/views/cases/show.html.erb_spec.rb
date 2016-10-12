require 'rails_helper'

RSpec.describe "cases/show.html.erb", type: :view do
  before do
    controller.singleton_class.class_eval do
      protected
        def marker_locations_for(cases)
          [Article.all]
        end
        helper_method :marker_locations_for
    end
  end
  describe "on success" do
     it 'should not display a content field' do
      this_case = FactoryGirl.create(:case)
      this_case.state = FactoryGirl.create(:state)
      assign(:case, this_case)
      assign(:commentable, this_case)
      assign(:comments, this_case.comments)
      assign(:comment, Comment.new)
      assign(:subjects, this_case.subjects)
      render
      expect(rendered).not_to match /only a stub/m
    end

    it 'displays litigation subheader if litigation text field is present' do
      this_case = FactoryGirl.create(:case, litigation: 'Legal Action')
      this_case.state = FactoryGirl.create(:state)
      assign(:case, this_case)
      assign(:commentable, this_case)
      assign(:comments, this_case.comments)
      assign(:comment, Comment.new)
      assign(:subjects, this_case.subjects)
      render
      expect(response.body).to match /Legal Action/m
    end

    it 'displays summary subheader if overview text field is present' do
      this_case = FactoryGirl.create(:case, overview: 'overview text')
      this_case.state = FactoryGirl.create(:state)
      assign(:case, this_case)
      assign(:commentable, this_case)
      assign(:comments, this_case.comments)
      assign(:comment, Comment.new)
      assign(:subjects, this_case.subjects)
      render
      expect(response.body).to match /Summary/m
    end

    it 'displays community action subheader if overview text field is present' do
      this_case = FactoryGirl.create(:case, community_action: 'community text')
      this_case.state = FactoryGirl.create(:state)
      assign(:case, this_case)
      assign(:commentable, this_case)
      assign(:comments, this_case.comments)
      assign(:comment, Comment.new)
      assign(:subjects, this_case.subjects)
      render
      expect(response.body).to match /Community and Family/m
    end
  end
end