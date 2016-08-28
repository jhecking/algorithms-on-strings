#!/usr/bin/env ruby -w

class Strings

  def self.kmp(text, pattern)
    str = pattern + '$' + text
    prefixes = compute_prefix_function(str)
    result = []
    len = pattern.length
    (len + 1).upto(str.length - 1) do |i|
      if prefixes[i] == len
        result << (i - 2 * len)
      end
    end
    result
  end

  def self.compute_prefix_function(text)
    s = Array.new(text.length)
    s[0] = 0
    border = 0
    1.upto(text.length-1) do |i|
      while (border > 0) && (text[i] != text[border])
        border = s[border - 1]
      end
      if text[i] == text[border]
        border += 1
      else
        border = 0
      end
      s[i] = border
    end
    s
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
when 'prefix_function'
  text = STDIN.readline.chop
  prefixes = Strings.compute_prefix_function(text)
  puts prefixes.join(' ')
when 'kmp'
  pattern = STDIN.readline.chop
  text = STDIN.readline.chop
  matches = Strings.kmp(text, pattern)
  puts matches.join(' ')
end

if profile
  profile = RubyProf.stop
  RubyProf::FlatPrinter.new(profile).print(STDOUT)
end
