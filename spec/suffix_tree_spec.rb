require_relative "../lib/suffix_tree"

describe SuffixTree do

  it "passes sample 1" do
    text = "A$"
    tree = described_class.new(text)
    nodes = tree.visit.map{|n| text[n.begin..n.end]}
    expect(nodes).to contain_exactly(*%w[ $ A$ ])
  end

  it "passes sample 2" do
    text = "ACA$"
    tree = described_class.new(text)
    nodes = tree.visit.map{|n| text[n.begin..n.end]}
    expect(nodes).to contain_exactly(*%w[ $ A $ CA$ CA$ ])
  end

  it "passes sample 3" do
    text = "ATAAATG$"
    tree = described_class.new(text)
    nodes = tree.visit.map{|n| text[n.begin..n.end]}
    expect(nodes).to contain_exactly(*%w[ AAATG$ G$ T ATG$ TG$ A A AAATG$ G$ T G$ $ ])
  end

  it "passes test case 4" do
    text = "AAA$"
    tree = described_class.new(text)
    nodes = tree.visit.map{|n| text[n.begin..n.end]}
    expect(nodes).to contain_exactly(*%w[ $ $ $ A A A$ ])
  end

end
