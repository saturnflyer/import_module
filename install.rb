#!/usr/bin/env ruby
# install command
# Ver. 1.0.0 (2003.05.01)

require 'rbconfig'
require 'getoptlong'
require 'ftools'

project = (File.split(Dir.getwd)).last.sub(/-((?:\d+\.)*\d+)\z/, "")
version = File.file?("VERSION") ? open("VERSION"){|f| f.read}.strip : $1

libname = project + "-" + version
libdir = "lib"
mandir = "doc"
logfile = "InstalledFiles"

destdir = Config::CONFIG["sitelibdir"]
destmandir = File.join(Config::CONFIG["prefix"], "doc", "ruby", libname, "doc")

instman = false
noharm = false

Usage = <<__END
  Usage: ruby install.rb [options]
  
      option      argument  action
      ------      --------  ------
      --destdir   dir       Destination dir
      -d                    (default is #{destdir})
      
      --mandir    dir       Manual dir
                            (default is #{destmandir})
      
      --man                 Install manuals

      --help                Print this help
      -h
      
      --noharm              Do not install, just print commands
      -n
__END

opts = GetoptLong.new(
  [ "--destdir",   "-d",            GetoptLong::REQUIRED_ARGUMENT ],
  [ "--mandir",                     GetoptLong::REQUIRED_ARGUMENT ],
  [ "--man",       "-m",            GetoptLong::NO_ARGUMENT       ],
  [ "--help",      "-h",            GetoptLong::NO_ARGUMENT       ],
  [ "--noharm",    "-n",            GetoptLong::NO_ARGUMENT       ]
)

opts.each do |opt, arg|
  case opt
  when '--destdir', '-d'
    destdir = arg
  when '--man', '-m'
    instman = true
  when '--mantdir'
    destmandir = arg
  when '--help', '-h'
    print Usage, "\n"
    exit
  when '--noharm', '-n'
    noharm = true
  else
    raise "unrecognized option: ", opt
  end
end

raise ArgumentError,
  "unrecognized arguments #{ARGV.join(' ')}" unless ARGV == []

files = []
unless instman
  Dir.glob(libdir + "/**/*").each do |file|
    tfile = File.join(destdir, File.basename(file))
    files.push [file, tfile]
  end
end
if instman
  Dir.glob(mandir + "/**/*").each do |file|
    tfile = File.join(destmandir, File.basename(file))
    files.push [file, tfile]
  end
end

log = open(logfile, "a") unless noharm
dirs = {}
for src, dest in files
  d = File.dirname(dest)
  if !dirs[d] && !File.directory?(d)
    puts "File.makedir #{d}"
    File.makedirs(d) unless noharm
    dirs[d] = true
  end
  puts "File.install #{src}, #{dest}, 0644, false"
  File.install(src, dest, 0644, false) unless noharm
  log.puts dest unless noharm
end
log.close unless noharm
