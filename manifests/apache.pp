# == Define: trac::apache
#
# Define to handle automatic creation of apache virtualhost. Should be called
# by tracenv define. This define utilizes the puppetlabs apache module.
#
# === Parameters
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
#   The root path of the trac environment calling the apache define
#
# [*envpath_setype*]
#   Selinux type to set for related files.
#
# [*redir_http*]
#   Boolean value. Set to true if you want to set up a vhost to redirect all
#   http traffic to https.
#
# [*vhost_name*]
#   The fqdn of your named virtualhost. Wildcards with '*' are acceptable.
#   Setting of this parameter is enforced by the trac::tracenv define.
#
# === Examples
#
# This define is intended to be called from a tracenv define. A typical call
# might be:
#
#    trac::apache{$name:
#      apache_user    => 'apache',
#      apache_group   => 'apache',
#      envpath        => '/trac/someenv,
#      envpath_setype => 'httpd_sys_rw_content_t',
#      vhost_name     => '*',
#      redir_http     => true,
#    }
#
#
define trac::apache(
  $apache_user    = $trac::params::apache_user,
  $apache_group   = $trac::params::apache_group,
  $envpath        = undef,
  $envpath_setype = undef,
  $redir_http     = false,
  $vhost_docroot  = "/var/www",
  $vhost_name     = undef,  
){
  #check to see if apache is already defined so we don't hit a conflict.
  if ! defined (Class['::apache']) {
    class{'::apache':
      default_vhost => false,
    }
    if ($::osfamily == 'Debian') {
      apache::mod {'auth_digest':}  
      if ($::apache::version::default >= 2.4) {
        apache::mod {'authn_core':}
      }
    }
    apache::mod {'wsgi':}
  }
    
  #dummy http (port 80) vhost for redirection to https
  if $redir_http {
    if ! defined (Apache::Vhost['redir_http_host']) {
      apache::vhost {'redir_http_host':
        port         => '80',
        docroot      => $vhost_docroot,
        rewrites     => [
          {
            rewrite_cond => ['%{HTTPS} off'],
            rewrite_rule => ['(.*) https://%{HTTP_HOST}%{REQUEST_URI}'],  
          },
        ],
      }
    }    
  }
    
   

  # The "real" vhost. $vhost_name must be different for each tracenv you call.
  apache::vhost{$name:
    vhost_name      => $vhost_name,
    port            => '443',
    docroot         => $vhost_docroot,
    ssl             => true,
    custom_fragment => "WSGIScriptAlias /$name ${envpath}/apache/trac.wsgi", 
      
    directories     => [ 
      { path               => $vhost_docroot, 
        options            => ['FollowSymLinks', 'MultiViews']},
          
      { path               => "${envpath}/apache", 
        custom_fragment    => 'WSGIApplicationGroup %{GLOBAL}', 
        order              => 'deny,allow', 
        allow              => 'from all'},
          
      { path               => "/$name/login",
        provider           => 'location',
        auth_type          => 'Digest',
        auth_name          => "$name",
        auth_digest_domain => $name,
        auth_user_file     => "$envpath/.htpasswd",
        auth_require       => 'valid-user',
      },
    ],
  }
  
  #make auth file
  file{"$envpath/.htpasswd":
    ensure  => 'present',
    mode    => '600',
    owner   => $apache_user,
    group   => $apache_group,
    seltype => $envpath_setype,
    require => File[$envpath],
  }
    
  #make directory for apache file
  file{"$envpath/apache":
    ensure  => 'directory',
    require => File[$envpath],
  }
    
  #wsgi trac bootstrap
  file{"$envpath/apache/trac.wsgi":
    ensure  => 'present',
    mode    => '644',
    owner   => $apache_user,
    group   => $apache_group,
    content => template('trac/trac.wsgi.erb'),
    seltype => $envpath_setype,
    require => File["$envpath/apache"],
  }
}
