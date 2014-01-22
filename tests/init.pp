# The baseline for module testing.
#
class{'trac':
  open_firewall => true,
}
trac::tracenv{'test':
  redir_http => true,
  vhost_name => '*',
}
