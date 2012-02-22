#! /nfs/users/ma/lwickland/.ruby-1.6.8/usr/local/bin/ruby
#puts `pwd`
#if %r{^.*/trunk[^/]*/?(.*?)$} =~ `pwd`
if %r{^.*/lwickland/src/[^/]+/?(.*?)$} =~ `pwd`
  workingDir = $1
else
  puts "You're not in a directory that's parented by 'lwickland/src'.  I don't know what to think."
  exit
end
output = `cvs diff 2> /dev/null`
output.each {|line|
  if %r{^RCS file: /nfs/src/cvsroot/((?:rnt|test|rnw)/.*?),v$} =~ line
    filename = $1.sub(/\/Attic\//, '/')
    if (workingDir.length == 0)
      puts filename
    elsif filename[0,workingDir.length] === workingDir
      puts filename[(workingDir.length + 1)..(-1)]
    else
      puts "That's odd.  #{filename} doesn't contain the working directory."
      exit
    end
  end
}
