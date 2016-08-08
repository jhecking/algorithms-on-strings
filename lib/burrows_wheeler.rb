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
    chars = self.chars
    rank = Hash.new(0)
    last = chars.map {|c| r = rank[c]; rank[c] += 1; [c, r]}
    i = 0
    index = rank.sort.inject({}){|hsh, (c, cnt)| hsh[c] = i; i+=cnt; hsh}
    inverse = ["$"]
    idx = 0
    (length-1).times do
      c = last[idx]
      inverse << c.first
      idx = index[c.first] + c.last
    end
    inverse.reverse.join
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
