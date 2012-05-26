#! /usr/bin/env ruby
# Roughly the equivalent of:
#   git diff -no-ext-diff --relative --name-only
repo = `cat CVS/Repository`.strip
if repo == "" 
  $stderr.puts "The current directory doesn't have a CVS/Repository file.  I give up."
  exit
end
# I tend to work in CVS repos where the first segment doesn't match the directory it's actually on disk.
if %r{^[^/]+/(.+)$} =~ repo
  repo = $1
end
diffs = `cvs -q diff 2> /dev/null | grep RCS.file`
diffs.split("\n").each {|line|
  if /^.*#{repo}\/(.+),v$/ =~ line
    puts $1
  else 
    $stderr.puts "I couldn't get #{line} to match #{repo}."
  end
}
