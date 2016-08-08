require 'spec_helper'
require_relative "../lib/burrows_wheeler"

describe "String#burrows_wheeler_transformation" do

  it "sample 1" do
    subject = "AA$"
    expect(subject.bwt).to eq("AA$")
  end

  it "sample 2" do
    subject = "ACACACAC$"
    expect(subject.bwt).to eq("CCCC$AAAA")
  end

  it "sample 3" do
    subject = "AGACATA$"
    expect(subject.bwt).to eq("ATG$CAAA")
  end

end
