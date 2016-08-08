#!/usr/bin/env ruby -w
#
module Enumerable
  def stable_sort_by
    sort_by.with_index { |x, idx| [yield(x), idx] }
  end
end

class String
  def burrows_wheeler_transformation
    chars = self.chars
    matrix = []
    length.times do 
      matrix << chars
      chars = chars.rotate(-1)
    end
    matrix = matrix.stable_sort_by(&:join)
    matrix.map(&:last).join
  end
  alias_method :bwt, :burrows_wheeler_transformation
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
end

if profile
  profile = RubyProf.stop
  RubyProf::FlatPrinter.new(profile).print(STDOUT)
end
