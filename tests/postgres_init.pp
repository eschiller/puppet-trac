# manifest for testing trac module with postgres databases
class{'trac':
  open_firewall => true,
}
trac::tracenv{'test':
  redir_http  => true,
  vhost_name  => '*',
  db_type     => 'postgres',
  db_user     => 'testenv_user',
  db_password => "NowWithPostgres",
}