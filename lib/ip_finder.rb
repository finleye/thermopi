require "socket"
require "ipaddr"
require "timeout"

class IpFinder
  GOOGLE_IP = "64.233.187.99"

  def self.find(mac_partial)
    ip = UDPSocket.open {|s| s.connect(GOOGLE_IP, 1); s.addr.last}
    ips = `nmap -sP #{ip.split('.')[0..-2].join('.')}1/24 > /dev/null && arp -na | grep #{mac_partial}`
      .split("\n")
      .reject { |host| host =~ /<incomplete>/ }
      .map { |device| /\((\d+\.\d+\.\d+\.\d+)\)/.match(device)[1] }
  end
end
