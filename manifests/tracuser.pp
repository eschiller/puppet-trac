# == Define: trac::trac_user
#
# Define a trac_user object. While the object itself can be 
# created directly, this indirection allows us to require 
# the proper realm be created first. 
# 
# [*password*]
#   The unencrypted password. Will be stored on disk via md5 hash
# 
# [*realm*] 
#   This must match the tracenv the user will be placed in. 
# 
# === Examples 
# 
#    trac::trac_user{ 'testuser1':
#        password => 'unencryptedPass',
#        realm    => 'tracRealm',
#    } 
#

define trac::tracuser( 
   $ensure   = present,
   $password = "",
   $realm    = "", 
) { 

  tracuser { $name: 
    ensure   => $ensure,
    password => $password,
    realm    => $realm,
    require  => Trac::Tracenv[$realm],
  } 
} 
