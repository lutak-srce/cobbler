#
# = Define: cobbler::del_distro
#
# Deletes cobblerdistro and it's kickstart
define cobbler::del_distro (
  $kickstarts_path = '/var/lib/cobbler/kickstarts'
){
  include ::cobbler

  $distro = $title
  cobblerdistro { $distro :
    ensure  => absent,
    destdir => $cobbler::distro_path,
    require => [ Service['cobbler'], Service['httpd'] ],
  }
  file { "${kickstarts_path}/${distro}.ks":
    ensure  => absent,
  }
}
