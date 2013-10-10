require 'spec_helper'

describe AdminNotifications do
  it "should deliver problem message" do
    @expected.subject = "Problem"
    @expected.to      = "to@example.org"
    @expected.from    = "from@example.com"
    @expected.body    = read_fixture("problem")
  end

end
