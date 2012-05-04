#! /nfs/users/ma/lwickland/.ruby-1.6.8/usr/local/bin/ruby
repo = `cat CVS/Repository`.strip
if repo == "" 
  puts " The current directory doesn't have a CVS/Repository file.  I give up."
  exit
end
# I tend to work in CVS repos where the first segment doesn't match the directory it's actually on disk.
if %r{^[^/]+/(.+)$} =~ repo
  repo = $1
end
diffs = `cvs -q diff 2> /dev/null | grep RCS.file`
puts "Diffs\n" 
puts diffs
diffs.each {|line|
  if /^.*#{repo}\/(.+),v$/ =~ line
    puts $1
  else 
    puts "I couldn't get #{line} to match #{repo}."
  end
}
