# manifest for testing git repos with trac module
class{'trac':
  open_firewall => true,
}
trac::tracenv{'test':
  redir_http => true,
  vhost_name => '*',
  repo_type  => 'git',
}