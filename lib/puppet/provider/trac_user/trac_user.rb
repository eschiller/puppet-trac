require 'digest'
require 'tempfile'

Puppet::Type.type(:trac_user).provide(:trac_user) do
	confine :feature => :posix

	defaultfor :kernel	=> "Linux"

	desc "Adds users for HTDigest" 

	def create
			passwordFile = File.open("/trac/#{@resource[:realm]}/.htpasswd", 'a')
			encryptedPW = Digest::MD5.hexdigest(@resource[:password])
			passwordFile.write("#{@resource[:name]}:#{@resource[:realm]}:#{encryptedPW}\n")
			passwordFile.close
	end

	def destroy 
		tmpFile = Tempfile.new('tracUser')
		IO.readlines("/trac/#{@resource[:realm]}/.htpasswd").map do |line|
			tmpFile.write(line) unless /^#{@resource[:name]}:#{@resource[:realm]}/.match(line)
		end
		tmpFile.rewind
		File.open("/trac/#{@resource[:realm]}/.htpasswd", 'w') do |file|
			file.puts tmpFile.read
		end
	end

	def exists?
		f = open("/trac/#{@resource[:realm]}/.htpasswd", "r")
		if f.grep(/^#{@resource[:name]}:#{@resource[:realm]}:/).count > 0
			return true
		end
	end

end


