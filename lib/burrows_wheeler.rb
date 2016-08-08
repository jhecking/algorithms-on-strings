#!/usr/bin/env ruby -w

class String

  def burrows_wheeler_transformation
    chars = self.chars
    matrix = []
    length.times do 
      matrix << chars
      chars = chars.rotate(-1)
    end
    matrix = matrix.sort_by(&:join)
    matrix.map(&:last).join
  end
  alias_method :bwt, :burrows_wheeler_transformation

  def burrows_wheeler_inverse
    last = self.chars.each_with_index.to_a
    first = last.sort
    last = last.map{|t| t.join("\0")}
    first = first.map{|t| t.join("\0")}
    inverse = []
    idx = 0
    length.times do
      inverse << first[idx]
      c = last[idx]
      idx = first.index(c)
    end
    inverse.reverse.map{|t| t.split("\0").first}.join
  end
  alias_method :bwtinverse, :burrows_wheeler_inverse
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
when 'bwt'
  text = STDIN.readline.chop
  puts text.bwt
when 'bwtinverse'
  text = STDIN.readline.chop
  puts text.bwtinverse
end

if profile
  profile = RubyProf.stop
  RubyProf::FlatPrinter.new(profile).print(STDOUT)
end
