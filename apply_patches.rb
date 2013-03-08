#!/usr/bin/env ruby

Dir["/Users/tekkub/Downloads/*.diff"].each do |f|
  /\d\.\d\.\d\.(?<before>\d+)-(?<after>\d+)\.diff$/ =~ f
  puts "\n~~~~~~~~~~~~~~ Applying build #{after} ~~~~~~~~~~~~~~"
  puts `git apply "#{f}"`
  puts `git add .`
  puts `git commit -m 'Build #{after}'`
end
