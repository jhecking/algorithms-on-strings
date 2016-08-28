#!/usr/bin/env ruby -w
require 'set'

class SuffixTreeNode
  @@idx = -1
  attr_accessor :idx, :s
  attr_accessor :parent, :children, :string_depth, :edge_start, :edge_end

  def initialize(children: {}, parent: nil, string_depth: 0,
                 edge_start: -1, edge_end: -1,
                 s: nil)
    @@idx += 1
    self.idx = @@idx
    self.s = s || parent.s
    self.children = children
    self.parent = parent
    self.string_depth = string_depth
    self.edge_start = edge_start
    self.edge_end = edge_end
    # puts "creating new node: #{self.inspect}"
  end

  def to_s
    @parent.nil? ?
      "#<STN:Root>"
      :
      "#<STN:#{idx}>"
  end

  def inspect
    @parent.nil? ?
      "#<STN:Root @children=#{@children} @string_depth=#{@string_depth}>"
      :
      "#<STN:#{idx} @parent=#{@parent} @children=#{@children} @string_depth=#{@string_depth} edge=#{@edge_start}..#{@edge_end}(#{s[@edge_start..@edge_end]})>"
  end
end

module SuffixArray
  def self.build_suffix_array(s)
    order = sort_characters(s)
    klass = compute_char_classes(s, order)
    l = 1
    while l < s.length
      order = sort_doubled(s, l, order, klass)
      klass = update_classes(order, klass, l)
      l *= 2
    end
    order
  end

  def self.sort_characters(s)
    len = s.length
    order = Array.new(len)
    count = Hash.new(0)
    alphabet = Set.new()
    s.chars.each do |c| 
      count[c] += 1
      alphabet << c
    end
    alphabet = alphabet.sort
    1.upto(alphabet.length - 1) do |j|
      count[alphabet[j]] += count[alphabet[j - 1]]
    end
    (len - 1).downto(0) do |i|
      c = s[i]
      count[c] -= 1
      order[count[c]] = i
    end
    return order
  end

  def self.compute_char_classes(s, order)
    len = s.length
    klass = Array.new(len)
    klass[order[0]] = 0
    1.upto(len - 1) do |i|
      if s[order[i]] != s[order[i-1]]
        klass[order[i]] = klass[order[i - 1]] + 1
      else
        klass[order[i]] = klass[order[i - 1]]
      end
    end
    return klass
  end

  def self.sort_doubled(s, l, order, klass)
    len = s.length
    count = Array.new(len, 0)
    newOrder = Array.new(len)
    0.upto(len - 1) do |i|
      count[klass[i]] += 1
    end
    1.upto(len - 1) do |j|
      count[j] += count[j - 1]
    end
    (len - 1).downto(0) do |i|
      start = (order[i] - l + len) % len
      cl = klass[start]
      count[cl] -= 1
      newOrder[count[cl]] = start
    end
    return newOrder
  end

  def self.update_classes(newOrder, klass, l)
    n = newOrder.length
    newKlass = Array.new(n)
    newKlass[newOrder[0]] = 0
    1.upto(n - 1) do |i|
      cur = newOrder[i]
      prev = newOrder[i - 1]
      mid = cur + l
      midPrev = (prev + l) % n
      if (klass[cur] != klass[prev]) || (klass[mid] != klass[midPrev])
        newKlass[cur] = newKlass[prev] + 1
      else
        newKlass[cur] = newKlass[prev]
      end
    end
    return newKlass
  end

  def self.suffix_tree_from_suffix_array(s, order, lcp_array)
    len = s.length
    root = SuffixTreeNode.new(s:s)
    lcp_prev = 0
    cur_node = root
    0.upto(len - 1) do |i|
      suffix = order[i]
      # puts "\n#{i}: cur_node=#{cur_node} lcp_prev=#{lcp_prev} suffix=#{suffix}:#{s[suffix..-1]}"
      while cur_node.string_depth > lcp_prev
        cur_node = cur_node.parent
      end
      if cur_node.string_depth == lcp_prev
        cur_node = create_new_leaf(cur_node, s, suffix)
      else
        edge_start = order[i - 1] + cur_node.string_depth
        offset = lcp_prev - cur_node.string_depth
        mid_node = break_edge(cur_node, s, edge_start, offset)
        cur_node = create_new_leaf(mid_node, s, suffix)
      end
      if i < len - 1
        lcp_prev = lcp_array[i]
      end
    end
    return root
  end

  def self.create_new_leaf(node, s, suffix)
    len = s.length
    leaf = SuffixTreeNode.new(parent: node,
                              string_depth: len - suffix,
                              edge_start: suffix + node.string_depth,
                              edge_end: len - 1)
    node.children[s[leaf.edge_start]] = leaf
    return leaf
  end

  def self.break_edge(node, s, start, offset)
    start_char = s[start]
    mid_char = s[start + offset]
    # puts "breaking edge: node=#{node} start=#{start} offset=#{offset} start_char=#{start_char} mid_char=#{mid_char}"
    # puts node.inspect
    mid_node = SuffixTreeNode.new(parent: node,
                                  string_depth: node.string_depth + offset,
                                  edge_start: start,
                                  edge_end: start + offset - 1)
    mid_node.children[mid_char] = node.children[start_char]
    node.children[start_char].parent = mid_node
    node.children[start_char].edge_start += offset
    node.children[start_char] = mid_node
    return mid_node
  end

  def self.compute_lcp_array(s, order)
    len = s.length
    lcp_array = Array.new(len - 1)
    lcp = 0
    pos_in_order = invert_suffix_array(order)
    suffix = order[0]
    0.upto(len - 1) do |i|
      order_index = pos_in_order[suffix]
      if order_index == len - 1
        lcp = 0
        suffix = (suffix + 1) % len
        next
      end
      next_suffix = order[order_index + 1]
      lcp = lcp_of_suffixes(s, suffix, next_suffix, lcp - 1)
      lcp_array[order_index] = lcp
      suffix = (suffix + 1) % len
    end
    return lcp_array
  end

  def self.lcp_of_suffixes(s, i, j, equal)
    len = s.length
    lcp = equal
    while i + lcp < len && j + lcp < len
      if s[i + lcp] == s[j + lcp]
        lcp += 1
      else
        break
      end
    end
    return lcp
  end

  def self.invert_suffix_array(order)
    pos = Array.new(order.length)
    0.upto(pos.length - 1) do |i|
      pos[order[i]] = i
    end
    return pos
  end

  def self.walk(node, &block)
    nodes = [node]
    while (node = nodes.shift)
      block.call(node)
      children = node.children.each.sort.map(&:last)
      nodes.unshift(*children)
    end
  end
end

case File.basename($0, '.*')
when 'suffix_array'
  s = readline.chomp
  sarray = SuffixArray.build_suffix_array(s)
  puts sarray.join(' ')
when 'suffix_tree_from_array'
  s = readline.chomp
  order = readline.chomp.split(' ').map(&:to_i)
  lcp_array = readline.chomp.split(' ').map(&:to_i)
  stree = SuffixArray.suffix_tree_from_suffix_array(s, order, lcp_array)
  puts s
  SuffixArray.walk(stree) do |node|
    next if node.parent.nil?
    puts [node.edge_start, node.edge_end + 1].join(' ')
  end
end
