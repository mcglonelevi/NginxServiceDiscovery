require 'dnsruby'
require 'erb'
require 'ostruct'

def createsig(body)
  Digest::MD5.hexdigest( sigflat body )
end

def sigflat(body)
  if body.class == Hash
    arr = []
    body.each do |key, value|
      arr << "#{sigflat key}=>#{sigflat value}"
    end
    body = arr
  end
  if body.class == Array
    str = ''
    body.map! do |value|
      sigflat value
    end.sort!.each do |value|
      str << value
    end
  end
  if body.class != String
    body = body.to_s << body.class.to_s
  end
  body
end

def erb(addresses)
  ERB.new(File.read('nginx.erb')).result(OpenStruct.new(:addresses => addresses).instance_eval { binding })
end

def init
  res = Dnsruby::Resolver.new
  res.query("web").answer
end

def set_config(addresses)
    puts addresses.inspect
    erb(addresses)
end

current_dns = init
output = set_config(current_dns)
open('/etc/nginx/nginx.conf', 'w') { |f| f.puts output }
system("nginx -s reload")

while true
    sleep 60
    current_dns = init
    output = set_config(current_dns)
    open('/etc/nginx/nginx.conf', 'w') { |f| f.puts output }
    system("nginx -s reload")
end
