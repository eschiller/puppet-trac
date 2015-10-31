# == Define: trac::apache
#
# Define to handle automatic creation of a vcs repository for a trac
# environment. Currently, git and svn repository creation is supported.
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
# [*envpath*]
#   The root path of the trac environment calling the apache define.
#
# [*envpath_setype*]
#   Selinux type to set for related files.
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
# === Examples
#
# This define is intended to be called from a tracenv define. A typical call
# might be:
#
#    trac::repo{$name:
#      envpath    => '/trac/test',
#      repo_group => 'developers',
#      repo_type  => 'git',
#    }
#
#
define trac::repo(
  $adjust_selinux = undef,
  $apache_user    = $trac::params::apache_user,
  $envpath        = undef,
  $envpath_setype = undef,
  $repo_group     = undef,
  $repo_location  = undef,
  $repo_type      = undef,
){
  # Sets the variables for the path of the repo, and the housing directory
  # If using the default repo paths, a parent dir named repos is created.
  # If a custom repo path is set, we can't know what the parent directory is,
  # or if it should be handled like the rest of the repos (with respect to 
  # selinux changes that are done by the module), so repo_dir is simply set
  # to the repo path.

  if $repo_location {
    $_repo_location = $repo_location
    $repo_dir = $repo_location
  } else {
    $repo_dir = "$envpath/repos"
    if ! defined ( File[$repodir] ) {
      file{$repo_dir:
        ensure  => 'directory',
        notify  => Vcsrepo[$name],
        require => File[$envpath],
      }
    }
    $_repo_location = "${repo_dir}/$name"
  }

    
  if ($repo_type == 'svn') {  

    realize Package['subversion']

    vcsrepo { $name:
      ensure   => present,
      provider => svn,
      path     => $_repo_location,
      require  => [
        File[$envpath],
        Package[subversion],
      ],
    }
    

  }
  
  if ($repo_type == 'git') {
    vcsrepo { $name:
      ensure   => bare,
      provider => git,
      path     => $_repo_location,
      require  => File[$envpath]
    }
  }
  
  #fixes SELinux perms
  if $adjust_selinux {
    exec{"${name}_fixrepocontext":
      command   => "chcon -R -t $envpath_setype $repo_dir",
      logoutput => "on_failure",
      path      => ["/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
      require   => Vcsrepo[$name],
    }
  }
  
  #fixes ownership
  exec{"${name}_repo_perms":
    command    => "chown -R ${apache_user}:$repo_group $_repo_location ; chmod -R g+w $_repo_location",
    logoutput => "on_failure",
    path      => ["/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
    require   => Vcsrepo[$name],
  }
  
  group{$repo_group:
    ensure => 'present'
  }
}
