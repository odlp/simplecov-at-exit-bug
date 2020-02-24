# Commenting this line out means the at_exit hooks fire correctly
require "active_support/test_case"

RSpec.describe "foo" do
  it "foos" do
    expect("foo").to eq "foo"
  end
end
