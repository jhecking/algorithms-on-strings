require_relative "../lib/tries"

describe Trie do

  describe ".load" do
    it "initializes a trie with a number of patterns read from an input stream" do
      subject = described_class.load StringIO.new <<EOT
2
foo
bar
EOT
     expect(subject.visit.count).to eq(7)
    end
  end

  describe "#initialize" do
    it "creates a new trie with a root node" do
      subject = described_class.new
      expect(subject.root).to be_leaf
    end

    it "adds the passed patterns to the tree" do
      subject = described_class.new(%w[ foo bar ])
      expect(subject.visit.count).to eq(7)
    end
  end

  describe "#visit" do
    it "visits every node in the trie once" do
      subject = described_class.new(%w[ foo bar ])
      nodes = subject.visit
      expect(nodes.map(&:index).sort).to eq([0, 1, 2, 3, 4, 5, 6])
    end
  end

  describe "#match" do
    it "returns a list of matches" do
      subject = described_class.new(%w[A AT AG])
      matches = subject.match("ACATA")
      expect(matches).to contain_exactly([0, "A"], [2, "A"], [4, "A"])
    end
  end

end
