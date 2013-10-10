require 'spec_helper'

describe "communities/edit.html.haml" do
  before(:each) do
    @community = assign(:community, stub_model(Community,
      :new_record? => false
    ))
  end

  it "renders the edit community form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => community_path(@community), :method => "post" do
    end
  end
end
