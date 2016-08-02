#!/usr/bin/env ruby -w
#
class Trie
  attr_reader :root
  attr_reader :index

  Node = Struct.new(:index, :edges) do
    def has_edge?(e)
      edges.has_key?(e)
    end
    def leaf?
      edges.empty?
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

  def match_prefix(text)
    chars = text.each_char
    s = chars.next
    v = root
    path = []
    loop do
      if v.leaf?
        return path.join
      elsif v.has_edge?(s)
        path << s
        v = v.edges[s]
        s = chars.next
      else
        return
      end
    end
  end

  def match(text)
    matches = []
    0.upto(text.length - 1) do |i|
      m = match_prefix(text[i..-1])
      matches << [i, m] if m
    end
    matches
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
when 'trie_matching'
  text = STDIN.readline
  trie = Trie.load(STDIN)
  matches = trie.match(text)
  puts matches.map(&:first).join(' ')
end
