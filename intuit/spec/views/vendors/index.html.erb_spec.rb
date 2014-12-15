require 'rails_helper'

RSpec.describe "vendors/index", :type => :view do
  before(:each) do
    assign(:vendors, [
      Vendor.create!(
        :name => "Name"
      ),
      Vendor.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of vendors" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
