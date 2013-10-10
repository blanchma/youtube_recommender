require 'spec_helper'

describe "communities/new.html.haml" do
  before(:each) do
    assign(:community, stub_model(Community).as_new_record)
  end

  it "renders new community form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => communities_path, :method => "post" do
    end
  end
end
