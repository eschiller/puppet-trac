Puppet::Type.type(:trac_user).provide(:trac_user) do
	confine :feature => :posix

	defaultfor :kernel	=> "Linux"

	desc "Adds users for HTDigest" 

	def create
		begin
			passwordFile = File.open("/tmp/myfile.txt", 'w')
			passwordFile.close
		end
	end

	def destroy 
		begin
		end
	end

	def exists?
		begin
			return File.exist?('/tmp/myfile.txt')
		end
	end

end


