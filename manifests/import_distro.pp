# Define: cobbler::import_distro
define cobbler::import_distro (
  $arch,
  $path,
  $available_as,
  $breed      = undef,
  $os_version = undef,
) {
  include cobbler
  $distro = $title
  $server_ip = $::cobbler::server_ip
  cobblerdistro { $distro :
    ensure     => present,
    arch       => $arch,
    path       => $path,
    breed      => $breed,
    os_version => $os_version,
    ks_meta    => { tree => $available_as },
    require    => [ Service['cobbler'], Service['httpd'] ],
  }
  $defaultrootpw = $::cobbler::defaultrootpw
  $kickstarts_path = $::cobbler::kickstarts_path
  file { "${kickstarts_path}/${distro}.ks":
    ensure  => present,
    content => template("cobbler/${distro}.ks.erb"),
    require => File[$kickstarts_path],
  }
}
