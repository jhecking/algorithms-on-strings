#!/usr/bin/env ruby -w
#
class Trie
  attr_reader :root
  attr_reader :index

  Node = Struct.new(:index, :edges) do
    def has_edge?(e)
      edges.has_key?(e)
    end
  end

  def self.load(io)
    count = io.readline.to_i
    patterns = io.take(count).map(&:chop)
    Trie.new(patterns)
  end

  def initialize(patterns = [])
    @index = 0
    @root = Node.new(index, {})
    patterns.each do |p|
      add(p)
    end
  end

  def add(pattern)
    curr = root
    pattern.each_char do |c|
      if curr.has_edge?(c)
        curr = curr.edges[c]
      else
        @index += 1
        curr = curr.edges[c] = Node.new(index, {})
      end
    end
  end

  def adjacencies
    adj = []
    stack = []
    curr = root
    while curr
      curr.edges.each do |label, child|
        adj << [curr.index, child.index, label]
        stack << child
      end
      curr = stack.pop
    end
    adj
  end

end

case File.basename($0, '.*')
when 'trie'
  trie = Trie.load(STDIN)
  trie.adjacencies.each do |edge|
    printf "%s->%s:%s\n", *edge
  end
end
