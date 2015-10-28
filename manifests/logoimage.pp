# == Define: trac::logoimage
#
# Define to handle automatic creation of logo image for new trac environment.
# This is automatically create with an Imagemagick command.
#
# === Parameters
#
# [*logo_path*]
#   The full path of the logo image file that will be created.
#
# [*im_package_name*]
#   The Imagemagick package name on the given platform.
#
# [*project_name*]
#   The name of the trac project we're creating a logo image for.
#
# === Examples
#
# This define is intended to be called from a tracenv define. A typical call
# might be:
#
#    trac::logoimage{$name:
#      logo_path     => '/trac/test/htdocs/logo.png',
#      project_name  => 'Test Project',
#    }
#
#
define trac::logoimage(
  $logo_path       = undef,
  $im_package_name = $trac::params::im_package_name,
  $project_name    = undef,
){
  exec{"${project_name}_create_logo":
    command   => "convert -background white -fill black -font Arial -size 220x label:$project_name $logo_path",
    logoutput => "on_failure",
    path      => ["/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
    creates   => "$logo_path",
    require   => Package[$im_package_name],
  }
}
