require 'socket'
 
if ARGV.length < 4
    $stderr.puts "Usage: #{$0} remoteHost:remotePort localPort localHost serviceName"
    exit 1
end
 
def waf()

end

$remoteHost, $remotePort = ARGV.shift.split(":")
puts "target address: #{$remoteHost}:#{$remotePort}"
localPort = ARGV.shift || $remotePort
localHost = ARGV.shift
@serviceName = ARGV.shift

Dir.mkdir("/tmp/#{@serviceName}/") unless Dir.exists?("/tmp/#{@serviceName}/")

$blockSize = 1024
 
server = TCPServer.open(localHost, localPort)
 
port = server.addr[1]
addrs = server.addr[2..-1].uniq
 
puts "*** listening on #{addrs.collect{|a|"#{a}:#{port}"}.join(' ')}"
Thread.abort_on_exception = true
Thread.new { loop { sleep 1 } }
 
def connThread(local)
    port, name = local.peeraddr[1..2]
    puts "*** receiving from #{name}:#{port}"
    f = File.open("/tmp/#{@serviceName}/#{name}.#{port}","wb+") 

    remote = TCPSocket.new($remoteHost, $remotePort)
     
    loop do
        ready = select([local, remote], nil, nil)
        if ready[0].include? local
            data = local.recv($blockSize)
	    d = "[client send (#{name})] #{data}\n"
	    f.write(d)
            if data.empty?
                puts "local end closed connection"
                break
            end
            remote.write(data)
        end
        if ready[0].include? remote
            data = remote.recv($blockSize)
	    d = "[server send message] #{data}\n"
	    f.write(d)
            if data.empty?
                puts "remote end closed connection"
                break
            end
            local.write(data)
        end
    end
     
    local.close
    remote.close
    f.close
    puts "*** done with #{name}:#{port}"
end
 
loop do
    Thread.start(server.accept) { |local| 
        begin
            connThread(local) 
        rescue
            next
        end
    }
end
