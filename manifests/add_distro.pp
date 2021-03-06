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
  $kickstarts_path   = '/var/lib/cobbler/kickstarts',
  $include_kickstart = true,
) {
  include ::cobbler

  $distro = $title
  $server_ip = $::cobbler::server_ip
  cobblerdistro { $distro :
    ensure  => present,
    arch    => $arch,
    isolink => $isolink,
    destdir => $::cobbler::distro_path,
    kernel  => "${::cobbler::distro_path}/${distro}/${kernel}",
    initrd  => "${::cobbler::distro_path}/${distro}/${initrd}",
    require => [ Service['cobbler'], Service['httpd'] ],
  }
  $defaultrootpw = $::cobbler::defaultrootpw
  if ($include_kickstart) {
    file { "${kickstarts_path}/${distro}.ks":
      ensure  => present,
      content => template($ks_template),
      require => File[$kickstarts_path],
    }
  }
}
