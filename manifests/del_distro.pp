#
# = Define: cobbler::del_distro
#
# Deletes cobblerdistro and it's kickstart
define cobbler::del_distro {
  include ::cobbler

  $distro = $title
  cobblerdistro { $distro :
    ensure  => absent,
    destdir => $::cobbler::distro_path,
    require => [ Service['cobbler'], Service['httpd'] ],
  }
  $kickstarts_path = $::cobbler::kickstarts_path
  file { "${kickstarts_path}/${distro}.ks":
    ensure  => absent,
  }
}
