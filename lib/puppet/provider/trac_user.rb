Puppet::Type.type(:trac_user).provide(:trac_user) do
	confine :feature => :posix

	desc "Adds users for HTDigest" 

	def create
	end

	def destroy 
	end

	def exists?
	end

end


