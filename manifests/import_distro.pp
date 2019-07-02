# Define: cobbler::import_distro
define cobbler::import_distro (
  $arch,
  $path,
  $available_as,
  $kickstarts_path = '/var/lib/cobbler/kickstarts',
) {
  include cobbler
  $distro = $title
  $server_ip = $::cobbler::server_ip
  cobblerdistro { $distro :
    ensure  => present,
    arch    => $arch,
    path    => $path,
    ks_meta => { tree => $available_as },
    require => [ Service['cobbler'], Service['httpd'] ],
  }
  $defaultrootpw = $::cobbler::defaultrootpw
  file { "${kickstarts_path}/${distro}.ks":
    ensure  => present,
    content => template("cobbler/${distro}.ks.erb"),
    require => File[$kickstarts_path],
  }
}
