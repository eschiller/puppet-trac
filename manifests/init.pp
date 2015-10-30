# == Class: trac
#
# Top level class for the trac module. 
#
# Although the trac::tracenv define does most of the heavy lifting of the 
# module, declaring this class is required for trac environments to be declared.
# 
# === Parameters
#
# [*easy_install*]
#   Boolean to decide if the whether trac should be installed via easy_install.
#   Defaults to true.
#
# [*easy_package*]
#   The name of the package that provides the easy_install command. Defaults to
#   python-setuptools.
#
# [*im_package_name*]
#   The Imagemagick package name on the given platform.
#
# [*open_firewall*]
#   Boolean which determines whether or not the trac module should open the
#   relevant firewall rules for you. Defaults to false.
#
# [*package_name*]
#   Name of trac package. Only used if easy_install is set to false, meaning
#   trac should be installed through traditional package management for the
#   given platform. This installation method is untested with the trac module.
#
# === Examples
#
#  Generally, a both the trac class and a trac::tracenv resource should be
#  declared to get a full trac installation. A fairly simple installation
#  would be declared as follows.
#
#    class { 'trac': }
#
#    trac::tracenv{ 'test':
#      redir_http => true,
#      vhost_name => '*',
#    }
#
#  More examples can be found in the tests directory, or in the trac::tracenv
#  documentation.
#
# === Authors
#
# Eric Schiller <ericgschiller@gmail.com>
#
class trac(
  $easy_install    = $trac::params::easy_install,
  $easy_package    = $trac::params::easy_package,
  $im_package_name = $trac::params::im_package_name,
  $open_firewall   = $trac::params::open_firewall,
  $package_name    = $trac::params::package_name,
) inherits trac::params {
  
  @package { $package_name: 
    ensure => 'installed', 
  }

  @package { 'python-subversion':
    ensure => present,
  }

  @package { 'subversion':
    ensure => latest,
  }

  
  #if we're using easy_install method, install via python easy install,
  #else install from distribution package management
  if ($easy_install) {
    package{$easy_package:
      ensure => 'installed'
    } 
    exec{'trac_easy_install':
      command => 'easy_install trac',
      path    => '/usr/bin',
      require => Package[$easy_package],
      creates => '/usr/bin/trac-admin',
    }
  } else {
    realisze Package[$package_name]
  }

  if ($open_firewall) {
    if ! defined(Class['firewall']) {
      class{'firewall':}
    }
    firewall{'100 open port 80':
      dport   => '80',
      proto   => 'tcp',
      action  => 'accept',
      require => Class['firewall']
    }
    firewall{'100 open port 443':
      dport   => '443',
      proto   => 'tcp',
      action  => 'accept',
      require => Class['firewall']
    }
  }
  
  #if using debian, install the python subversion bindings
  if ($::osfamily == 'Debian') {
    realize Package['python-subversion']
  }
  
  package{$im_package_name:
    ensure  => 'installed',
  }
  
  
  #some virtual resources needed to avoid conflicts
  @package{$sqlite_pkg:
    ensure => 'present'
  }
  
  #fixes errors with postgres connect caused by selinux
  @exec{"se_allow_httpd_network":
    command   => "setsebool -P httpd_can_network_connect on",
    logoutput => "on_failure",
    path      => ["/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
  }
}
