require 'spec_helper'

describe "communities/show.html.haml" do
  before(:each) do
    @community = assign(:community, stub_model(Community))
  end

  it "renders attributes in <p>" do
    render
  end
end
