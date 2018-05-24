#!/usr/bin/env ruby

def p64(*addr)
    return addr.pack("Q*")
end
def up64(str)
    return str.unpack("Q*")
end
if ARGV.length != 1
    puts "Usage : #{$0} serviceName"
    exit()
end

puts "[check #{ARGV[0]} log]"
filelist = {}
count = 0
Dir.foreach("/tmp/#{ARGV[0]}") do |f|
    next if f == ".." or f == "."
    puts "[#{count.to_s().rjust(3,"0")}] #{f} ,size : #{File.size("/tmp/#{ARGV[0]}/#{f}")}"
    filelist[count] = f
    count += 1
end

while true
    print "choose log to view > "
    idx = STDIN.gets().to_i()
    if idx < 0 or idx >= count
        puts "[!] Wrong index."
        next
    end
    #puts filelist[idx]
    if File.exist? "/tmp/#{ARGV[0]}/#{filelist[idx]}"
     f = File.open("/tmp/#{ARGV[0]}/#{filelist[idx]}", "rb")
        until f.eof?
            l = f.readline()
            puts l
        end
    end
end
