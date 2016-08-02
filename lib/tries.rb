#!/usr/bin/env ruby -w
#
class Trie
  attr_reader :root
  attr_reader :index

  Node = Struct.new(:index, :edges, :pattern_end) do
    def has_edge?(e)
      edges.has_key?(e)
    end
    def pattern_end?
      !!pattern_end
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
      if !curr.has_edge?(c)
        @index += 1
        curr.edges[c] = Node.new(index, {})
      end
      curr = curr.edges[c]
    end
    curr.pattern_end = true
  end

  def visit
    return enum_for(:visit) if !block_given?
    yield curr = root
    stack = []
    while curr
      curr.edges.each do |_, child|
        yield child
        stack << child
      end
      curr = stack.pop
    end
  end

  def match(text)
    matches = []
    chars = text.chars
    0.upto(text.length - 1) do |i|
      m = match_prefix(chars)
      matches << [i, m] if m
      chars.shift
    end
    matches
  end

  private

  def match_prefix(chars)
    chars = chars.clone
    s = chars.shift
    v = root
    path = []
    loop do
      if v.pattern_end?
        return path.join
      elsif v.has_edge?(s)
        path << s
        v = v.edges[s]
        s = chars.shift
      else
        return
      end
    end
  end
end

def adjacencies(trie)
  adj = []
  trie.visit do |node|
    node.edges.each do |label, child|
      adj << [node.index, child.index, label]
    end
  end
  adj
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
when 'trie'
  trie = Trie.load(STDIN)
  adjacencies(trie).each do |edge|
    printf "%s->%s:%s\n", *edge
  end
when 'trie_matching', 'trie_matching_extended'
  text = STDIN.readline
  trie = Trie.load(STDIN)
  matches = trie.match(text)
  puts matches.map(&:first).join(' ')
end

if profile
  profile = RubyProf.stop
  RubyProf::FlatPrinter.new(profile).print(STDOUT)
end
