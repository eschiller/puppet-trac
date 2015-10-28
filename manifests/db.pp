# == Define: trac::db
#
# Define to handle automatic creation of database for trac environment.
#
# Can be used for either sqlite databases or postgres databases, which is set
# in the db_type parameter.
#
# === Parameters
#
# [*adjust_selinux*]
#   Boolean value. Should be set to true if you'd like the define to
#   automatically fix the file attributes for selinux.
#
# [*apache_user*]
#   The name of user the apache service runs under, used to ensure proper
#   ownership of files the service needs access to.
#
# [*apache_group*]
#   The name of group the apache service runs under, used to ensure proper
#   ownership of files the service needs access to.
#
# [*db_password*]
#   Password for user with read/write to trac environment database. Only
#   applicable for Postgres database types.
#
# [*db_type*]
#   The provider of the database. Currently, 'sqlite' or 'postgres' are valid.
#
# [*db_user*]
#   User with read/write to trac environment database. Only applicable for
#   Postgres database types.
#
# [*envpath_setype*]
#   SELinux type that the trac environment has been set to.
#
# [*fulldbpath*]
#   Full path to the database file. This only applies to sqlite database types.
#
# [*pgpy_package_name*]
#   The name of the postgresql package on the given platform.
#
# [*sqlite_cmd*]
#   The command used to execute sqlite commands on the given platform.
#
# [*sqlite_pkg*]
#   The name of the sqlite package on the given platform.
#
# === Examples
#
# This define is intended to be called from a tracenv define. A typical call
# when using the 'sqlite' db_type would be:
#
#    trac::db{$name:
#      db_type        => 'sqlite',
#      fulldbpath     => '/trac/test/db/test.db',
#    }
#
# A typical call when using the 'postgres' db type would be:
#
#    trac::db{$name:
#      db_type     => 'postgres',
#      db_user     => 'database_user',
#      db_password => 'PGisGre@t!'
#    }
#
define trac::db(
  $adjust_selinux    = undef,
  $apache_group      = $trac::params::apache_group,
  $apache_user       = $trac::params::apache_user,
  $db_password       = undef,
  $db_type           = undef,
  $db_user           = undef,
  $envpath_setype    = undef,
  $fulldbpath        = undef,
  $pgpy_package_name = $trac::params::pgpy_package_name, 
  $sqlite_cmd        = $trac::params::sqlite_cmd,
  $sqlite_pkg        = $trac::params::sqlite_pkg,
){
  if ($db_type == 'sqlite') {
    
    realize Package[$sqlite_pkg]
    
    file{"${name}_db_loc":
      path   => $fulldbpath,
      ensure => present,
      owner  => $apache_user,
      group  => $apache_group,
      mode   => '755',
      notify => Exec["${name}_sqlite_db"],
    }
    
    exec{"${name}_sqlite_db":
      command   => "$sqlite_cmd $fulldbpath \".databases\"",
      logoutput => "on_failure",      
      path      => ["/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
      creates   => "$fulldbpath",
      require   => Package[$sqlite_pkg],
    }
    
    if $adjust_selinux {
      exec{"${name}_fixdbcontext":
        command   => "chcon -R -t $envpath_setype $fulldbpath",
        logoutput => "on_failure",
        path      => ["/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
        require   => Exec["${name}_sqlite_db"],
      }
    }
  } elsif ($db_type == 'postgres') {
    if ! defined(Class['postgresql::server']){
      class { 'postgresql::server': }
    }
    
    postgresql::server::db { "${name}_db":
      user     => $db_user,
      password => postgresql_password($db_user, $db_password),
      notify   => Exec["${name}_initenv"],
    }
    
    package{$pgpy_package_name:
      ensure => present
    }
    
    if $adjust_selinux {
      realize Exec['se_allow_httpd_network']
    }
  }
}
