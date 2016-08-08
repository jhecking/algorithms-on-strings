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

describe "String#burrows_wheeler_inverse" do

  it "sample 1" do
    subject = "AC$A"
    expect(subject.bwtinverse).to eq("ACA$")
  end

  it "sample 2" do
    subject = "AGGGAA$"
    expect(subject.bwtinverse).to eq("GAGAGA$")
  end

  it "test case 1" do
    subject = "TTCCTAACG$A"
    expect(subject.bwtinverse).to eq("TACATCACGT$")
  end
end
