Puppet::Type.newtype(:trac_user) do
	@doc = "Add trac users to htaccess"

	ensurable

	newparam(:name) do
		desc "The username to add"
		isnamevar
	end

	newparam(:password) do
		desc "The unencrypted password for the user"
	end

	newparam(:realm) do 
		desc "The HTDigest Realm for the user" 
	end

	newproperty(:path) do 
	end
end

