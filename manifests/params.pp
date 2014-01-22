# == Define: trac::params
#
# This is a utility class for storing default values for parameters used by
# other classes and defines in the trac module.
#
class trac::params() {
  case $::osfamily {
    'RedHat': {
      $package_name = 'trac'
      $apache_user = 'apache'
      $apache_group = 'apache'
      $im_package_name = 'ImageMagick'
      $pgpy_package_name = 'python-psycopg2'
      $sqlite_cmd = 'sqlite3'
      $sqlite_pkg = 'sqlite'
      if ($::selinux) {
        $adjust_selinux = true
      } else {
        $adjust_selinux = false
    }  
  }
    'Debian': {
      $package_name = 'trac'
      $apache_user = 'www-data'
      $apache_group = 'www-data'
      $adjust_selinux = false
      $im_package_name = 'imagemagick'
      $pgpy_package_name = 'python-psycopg2'
      $sqlite_cmd = 'sqlite3'
      $sqlite_pkg = 'sqlite3'
    }
  } 
  $easy_install = true
  $easy_package = 'python-setuptools'
  $open_firewall = false
}
