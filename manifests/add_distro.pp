#
# = Define: cobbler::add_distro
#
# Adds cobblerdistro coupled with kickstart.
define cobbler::add_distro (
  $arch,
  $isolink,
  $kernel            = 'images/pxeboot/vmlinuz',
  $initrd            = 'images/pxeboot/initrd.img',
  $ks_template       = "cobbler/${title}.ks.erb",
  $include_kickstart = true,
  $breed,
  $os_version,
) {
  include ::cobbler

  $distro = $title
  $server_ip = $::cobbler::server_ip
  cobblerdistro { $distro :
    ensure     => present,
    arch       => $arch,
    isolink    => $isolink,
    breed      => $breed,
    os_version => $os_version,
    destdir    => $::cobbler::distro_path,
    kernel     => "${::cobbler::distro_path}/${distro}/${kernel}",
    initrd     => "${::cobbler::distro_path}/${distro}/${initrd}",
    require    => [ Service['cobbler'], Service['httpd'] ],
  }
  $defaultrootpw = $::cobbler::defaultrootpw
  $kickstarts_path = $::cobbler::kickstarts_path
  if ($include_kickstart) {
    file { "${kickstarts_path}/${distro}.ks":
      ensure  => present,
      content => template($ks_template),
      require => File[$kickstarts_path],
    }
  }
}
