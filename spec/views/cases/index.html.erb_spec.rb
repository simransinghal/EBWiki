require 'rails_helper'

RSpec.describe "cases/index.html.erb", type: :view do

  it "displays all the cases" do
    assign(:cases, Kaminari.paginate_array([
      case1 = FactoryGirl.create(:case, :title => "John Doe"),
      case2 = FactoryGirl.create(:case, :title => "Jimmy Doe")
    ]).page(1))
    case1.state = FactoryGirl.create(:state)
    case2.state = case1.state

    render

    expect(rendered).to match /John Doe/m
    expect(rendered).to match /Jimmy Doe/m
  end
end