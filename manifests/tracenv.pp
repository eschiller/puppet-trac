# == Define: trac::tracenv
#
# Define to handle the creation of a new trac environment. This is the central
# define in the trac module, which most other resources (excepting the trac
# class) are called from.
#
# === Parameters
#
# [*adjust_selinux*]
#   Boolean value. Should be set to true if you'd like the define to
#   automatically fix the file attributes for selinux.
#
# [*apache_group*]
#   The name of group the apache service runs under, used to ensure proper
#   ownership of files the service needs access to.
#
# [*apache_user*]
#   The name of user the apache service runs under, used to ensure proper
#   ownership of files the service needs access to.
#
# [*create_db*]
#   Boolean to determine if a new database should be created for the trac
#   environment. Defaults to true (false is untested).
#
# [*create_repo*]
#   Boolean to determine if a new vcs repo should be created for the trac
#   environment. Defaults to true (false is untested).
#
# [*create_vhost*]
#   Boolean to determine if a new apache vhost should be created for the trac
#   environment. Defaults to true (false is untested).
#
# [*db_file*]
#   The file name of the database that will be created. Defaults to ${name}.db.
#   Only applicable if $db_type is set to 'sqlite'.
#
# [*db_loc*]
#   The file path of the directory hoousing the database that will be created. 
#   Defaults to ${envpath}/db. Only applicable if $db_type is set to 'sqlite'.
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
# [*envpath*]
#   The root path of the trac environment.
#
# [*redir_http*]
#   Boolean value. Set to true if you want to set up a vhost to redirect all
#   http traffic to https.
#
# [*repo_group*]
#   The group to give file ownership of the repository to.
#
# [*repo_location*]
#   The file path location of the repository. If this is altered from the
#   default, you must ensure that the directory housing the repo is created.
#
# [*repo_type*]
#   The specific version control system being used for the repository.
#   Currently, git and svn are supported.
#
# [*vhost_name*]
#   The fqdn of your named virtualhost. Wildcards with '*' are acceptable.
#   Setting of this parameter is enforced by the trac::tracenv define.
#
# === Examples
#
# The trac class must be declared first to meet dependencies.
#
# A simple trac environment called 'mytrac' will be created with the following
# declaration. Note that 'vhost_name' is the only parameter that is required by
# the trac::tracenv define.
#
#    trac::tracenv{'mytrac':
#      vhost_name => '*',
#    }
#
# A more complicated trac environment using postgres for the backend db, a Git 
# repository and http to https redirection is as follows:
#
#    trac::db{'mytrac':
#      db_type     => 'postgres',
#      db_user     => 'database_user',
#      db_password => 'PGisGre@t!',
#      repo_type   => 'git',
#    }
#
define trac::tracenv(
  $adjust_selinux = $trac::params::adjust_selinux,
  $apache_group   = $trac::params::apache_group,
  $apache_user    = $trac::params::apache_user,
  $create_db      = true,
  $create_repo    = true,
  $create_vhost   = true,
  $db_file        = undef,
  $db_loc         = undef,
  $db_password    = undef,
  $db_type        = 'sqlite',
  $db_user        = undef,
  $envpath        = "/trac/$name",
  $redir_http     = false,  
  $repo_group     = undef,
  $repo_location  = undef,
  $repo_type      = 'svn',
  $vhost_docroot  = "/var/www",
  $vhost_name     = undef,
) {
  if ! defined(Class['trac']) {
    fail('You must include the trac base class before using any trac defined resources')
  }
  if ! ($vhost_name) {
    fail('You must declare a $vhost_name for each defined tracenv')
  }
  if ($db_type == 'postgres' and ! ($db_user and $db_password)) {
    fail('$db_user and $db_password parameters must be set when using postgres')
  }
  
  # LET'S SET SOME VARIABLES!
  if $db_loc {
    $_db_loc = $db_loc
  } else {
    $_db_loc = "$envpath/db"
  }
  
  if $repo_group {
    $_repo_group = $repo_group
  } else {
    $_repo_group = $name
  }
  
  if $db_file {
    $_db_file = $db_file
  } elsif ($db_type == 'sqlite') {
    $_db_file = "${name}.db"
  } elsif ($db_type == 'postgres') {
    $_db_file = "${name}_db"
  }
  
  $fulldbpath = "$_db_loc/$_db_file"
  
  if ($db_type == 'sqlite') {
    $dburi = "$db_type:$fulldbpath"
  } elsif ($db_type == 'postgres') {
    $dburi = "$db_type://$db_user:$db_password@localhost/$_db_file"
  }
  
  if ($adjust_selinux) {
    $envpath_setype = 'httpd_sys_rw_content_t'
  } else {
    $envpath_setype = undef
  }

  if $repo_location {
    $_repo_location = $repo_location
  } else {
    $repo_dir = "$envpath/repos"
    $_repo_location = "${repo_dir}/$name"
  }
  
  # Create directory for trac files
  file{"$envpath":
    ensure  => 'directory',
    mode    => '644',
    owner   => $apache_user,
    group   => $apache_group,
    seltype => $envpath_setype,
    recurse => true,
    require => Exec["${name}_initenv"],
  }
  
  # Use trac-admin to initialize the trac environment
  exec{"${name}_initenv":
    command   => "mkdir -p $envpath; trac-admin $envpath initenv $name $dburi",
    logoutput => "on_failure",
    path      => ["/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
    creates   => "${envpath}/conf/trac.ini",
    require   => Exec['trac_easy_install'],
    notify    => File[$envpath],
  }
  
  file{"${envpath}/conf/trac.ini":
    ensure  => 'present',
    mode    => '644',
    owner   => $apache_user,
    group   => $apache_group,
    content => template('trac/trac.ini.erb'),
    seltype => $envpath_setype,
    require => Exec["${name}_initenv"],
  }
 
  # Make the header image
  trac::logoimage{"${name}_logo":
    project_name => $name,
    logo_path    => "$envpath/htdocs/${name}_logo.png",
    require      => Exec["${name}_initenv"],
  }
 
  # create apache vhost by calling trac::apache
  if $create_vhost {
    trac::apache{$name:
      apache_user    => $apache_user,
      apache_group   => $apache_group,
      envpath        => $envpath,
      envpath_setype => $envpath_setype,
      vhost_name     => $vhost_name,
      vhost_docroot  => $vhost_docroot,
      redir_http     => $redir_http,
    }
  }
 
  
  # Create db
  if $create_db {
    trac::db{$name:
      adjust_selinux => $adjust_selinux,
      db_user        => $db_user,
      db_password    => $db_password,
      db_type        => $db_type,
      envpath_setype => $envpath_setype,
      fulldbpath     => $fulldbpath,
    }
  }
  
  # create repository  
  if $create_repo {
    trac::repo{$name:
      adjust_selinux => $adjust_selinux,
      envpath        => $envpath,
      envpath_setype => $envpath_setype,
      repo_group     => $_repo_group,
      repo_location  => $repo_location,
      repo_type      => $repo_type,
    }
  }
}
