#!/usr/bin/env ruby -w

class SuffixTree
  Node = Struct.new(:begin, :end, :next, :child) do
    def len
      self.end - self.begin + 1
    end
    def to_s
      if self.begin
        "([#{self.begin}..#{self.end}], next: #{self.next}, child: #{self.child})"
      else
        "(<root>, next: #{self.next}, child: #{self.child})"
      end
    end
  end

  attr_reader :text
  attr_reader :root

  def initialize(text)
    @text = text
    @root = Node.new()
    suffixes(text) do |suffix|
      add(root, suffix)
    end
  end

  def visit(node = root, &block)
    return to_enum(:visit) unless block
    yield node unless node == root
    visit(node.next, &block) if node.next
    visit(node.child, &block) if node.child
  end

  def expand(node)
    text[node.begin..node.end]
  end

  private

  def suffixes(text)
    0.upto(text.length-1) do |i|
      yield Node.new(i, text.length-1)
    end
  end

  def add(node, suffix)
    return unless suffix
    if node.child
      insert_child(node.child, suffix)
    else
      node.child = suffix
    end
  end

  def insert_child(node, suffix)
    while node
      common = common_prefix(node, suffix)
      if common > 0
        if common == node.len && node.child
          suffix.begin += common
          insert_child(node.child, suffix)
        else
          node.child = Node.new(node.begin + common, node.end, nil, node.child)
          node.end = node.begin + common - 1
          if (suffix.len > common)
            suffix.begin += common
            node.child.next = suffix
          end
        end
        break
      else
        if node.next.nil?
          node.next = suffix
          break
        end
        node = node.next
      end
    end
  end

  def common_prefix(n1, n2)
    str1, str2 = expand(n1), expand(n2)
    len = [str1, str2].map(&:length).max
    idx = (0..len).each do |i|
      break i if str1[i] != str2[i]
    end
    idx = -1 unless idx > 0
    return idx
  end

end

profile = false
ARGV.each do |arg|
  case arg
  when '-p', '--prof' then profile = true
  end
end

if profile
  require 'ruby-prof'
  RubyProf.start
end

case File.basename($0, '.*')
when 'suffix_tree'
  text = STDIN.readline.chop
  tree = SuffixTree.new(text)
  tree.visit do |node|
    puts tree.expand(node)
  end
end

if profile
  profile = RubyProf.stop
  RubyProf::FlatPrinter.new(profile).print(STDOUT)
end
