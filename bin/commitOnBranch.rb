#! /nfs/users/ma/lwickland/.bin/.ruby19/bin/ruby

require 'fileutils'

def getRCMessage
    return "You need to have a ~/.commitOnBranch.rc file that contains lines like:\n" + 
    %q@    otherSourceTreeRoot = "/nfs/users/ma/lwickland/src/rnw-8-5-fixes/"@ + "\n" +
    %q@    changesDirectoryRegex = %r{^.*/trunk/?(.*?)$}@ + "\n\n" +
    %q@    These paths need to point to the directory which contains bin, common, rnw, etc.@ + "\n"
end

def getBackupMessage
    return "" if ($backups.nil? || $backups.size == 0)
    message = "Just to be a litte extra secure, your files were backed up:\n"
    $backups.keys.sort.each do |source|
        message += "  #{source}  =>\n"
        message += "    #{$backups[source]}\n"
    end
    return message
end

def reportError(message)
    puts ""
    puts "ERROR: #{message}"
    puts ""
    puts getBackupMessage
    exit 1
end

def getTempName
    name = "/tmp/commitOnBranch-#{Time.now.to_i.to_s}-#{rand(9999999).to_s}";
    return getTempName if File.exists?(name)
    return name 
end

def backup(files)
    files.each do |file|
        dest = getTempName()
        Dir.mkdir(dest)
        FileUtils.cp_r(files, dest)
        $backups[file] = dest
    end
end

def makePathsAbsoluteToCurrent(files)
    return files.map do |file|
        File.expand_path(file)
    end
end

def backupAndCvsUpdate(files, argifiedFiles, checkForModifications)
    backup(makePathsAbsoluteToCurrent(files))
    cvsUpdateOutput = `cvs up #{argifiedFiles}`
    reportError("CVS Update failed due to a conflict in #{Dir.getwd}.  It said:\n#{cvsUpdateOutput}") if cvsUpdateOutput =~ /^C /
    if (checkForModifications and cvsUpdateOutput =~ /^M /)
        reportError("CVS Update reported that one or more target files are modified in #{Dir.getwd}.\nFor your protection, I won't commit a file that might have unexpected changes.\nMake sure that cvs update doesn't report 'M' for any target files before trying again.\n\nCVS said:\n#{cvsUpdateOutput}")
    end
end

def checkThatCommitMessageLooksReasonable(commitMessage) 
    return if commitMessage =~ / /
    return if commitMessage =~ /\d{6}-\d{6}/
    reportError("Your commit message #{commitMessage} doesn't look particularly interesting.  I suggest you make it more informative.")
end

def prepareCommitMessage
    commitMessage = ARGV[0]
    checkThatCommitMessageLooksReasonable(commitMessage)
    commitMessagePath = getTempName()
    File.open(commitMessagePath, File::CREAT|File::TRUNC|File::RDWR, 0644) do |commitMessageFile|
        commitMessageFile.write(commitMessage)
    end
    return commitMessagePath
end

def printUsage(error)
    puts ""
    puts "ERROR: #{error}", "" if error
    puts "USAGE: \"commit message\" fileToCommit [fileToCommit]*"
    puts "       -r <.file.rc> Use the specified configuration file instead of ~/.commitOnBranch.rc"
    puts "       -d Do not commit.  Create patch file and apply it, but don't commit."
    puts "       -p Only create patch file.  Don't apply it.  CVS updates will happen."
    puts ""
    puts getRCMessage()
    puts ""
    exit 1
end

doNotCommit = false
onlyCreatePatch = false
rcPath = false
while ARGV.length > 0 && ARGV[0] =~ /^-[a-z]$/ #ARGV.length > 2 && 
    arg = ARGV.shift
    case arg
    when /^-r$/
        if ARGV.size > 0
            rcPath = ARGV.shift 
        else 
            printUsage("-r requires an argument")
        end
    when /^-d$/
        doNotCommit = true
    when /^-p$/
        onlyCreatePatch = true
    else
        printUsage("#{arg} is not a recognized switch.")
    end
end

if ARGV.length < 2
    if ARGV.length > 0 
        message = "ERROR: You must provide a commit message and files to commit." 
    else 
        message = false
    end
    printUsage(message)
end

$backups = Hash.new
otherSourceTreeRoot = nil
changesDirectoryRegex = nil
rcPath ||= ENV['HOME'] + "/.commitOnBranch.rc"
reportError(getRCMessage()) unless File.exists?(rcPath)
File.open(rcPath) do |file|
    eval(file.read())
end
reportError("It looks like your #{rcPath} doesn't define otherSourceTreeRoot and changesDirectoryRegex") if (otherSourceTreeRoot.nil? || changesDirectoryRegex.nil?)

if changesDirectoryRegex =~ `pwd`
  workingDir = $1
else
  reportError("You're not in a directory that's parented by your changes directory.  I quit.")
end

commitMessagePath = prepareCommitMessage
filesToCommit = ARGV[1..-1]
filesToCommitString = '"' + filesToCommit.join('" "') + '"'
patchFilePath = Dir.getwd + "/patch"

#puts "Commit Message: #{ARGV[0]}"
#puts "Files To Commit: #{filesToCommitString}"
#puts "Patch File Path: #{patchFilePath}"

backupAndCvsUpdate(filesToCommit, filesToCommitString, false)

#puts "About to execute: cvs diff -up #{filesToCommitString} > #{patchFilePath}"
cvsDiffOutput = `cvs diff -up #{filesToCommitString} > #{patchFilePath}`
reportError("It appears that nothing has changed in the files you specified.  CVS said:\n#{cvsDiffOutput}") unless (File.exists?(patchFilePath) && File.size(patchFilePath) > 4)

puts "The patch file is at #{patchFilePath}" if onlyCreatePatch || doNotCommit
exit if onlyCreatePatch

oldWorkingDir = Dir.getwd
Dir.chdir(otherSourceTreeRoot + workingDir)
backupAndCvsUpdate(filesToCommit, filesToCommitString, true)

# If the patch happens too quickly then CVS doesn't think anything has changed
# because the file modification time is the same as the CVS update time.
sleep(1)

dryRunOutput = `patch -Np0 --dry-run < #{patchFilePath}`
reportError("The patch dry run failed.  This is what it said:\n#{dryRunOutput}") unless $? == 0

patchOutput = `patch -Np0 < #{patchFilePath}`
reportError("The patch failed.  This is what it said:\n#{patchOutput}") unless $? == 0

commitCommand = "cvs ci -F \"#{commitMessagePath}\" #{filesToCommitString}"
if doNotCommit
    puts "In #{Dir.getwd()} would execute: #{commitCommand}"
    puts "In #{oldWorkingDir} would execute: #{commitCommand}"
    Dir.chdir(oldWorkingDir)
else
    cvsCommitOutput = `#{commitCommand}`
    reportError("The CVS commit in the other directory failed.  This is what it said:\n#{cvsCommitOutput}") unless $? == 0
    Dir.chdir(oldWorkingDir)
    cvsCommitOutput = `#{commitCommand}`
    reportError("The CVS commit here failed.  This is what it said:\n#{cvsCommitOutput}") unless $? == 0
end

File.delete(commitMessagePath)
FileUtils.rm_r($backups.values)
exit if doNotCommit
File.delete(patchFilePath)

puts "\n\nIt looks like your stuff was committed on both branches successfully.  I suggest you go double check.\n\n"

puts ((filesToCommit.map { |file| "http://teton/cgi-bin/cvs/cvsweb/rnt/#{workingDir}/#{file}"}).join("\n"))
puts "\n\nHere's what I think you committed:\n"
puts filesToCommit.join("\n")
