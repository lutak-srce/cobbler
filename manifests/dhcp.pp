#
# = Class: cobbler::dhcp
#
# This module manages ISC DHCP for Cobbler
#
class cobbler::dhcp (
  $package         = undef,
  $service         = undef,
  $tmpl_dhcp_conf  = 'cobbler/dhcp.template.erb',
  $nameservers     = undef,
  $interfaces      = undef,
  $subnets         = undef,
  $dynamic_range   = false,
) inherits cobbler::params {
  include ::cobbler

  package { 'dhcp': name => $package, }

  service { 'dhcpd':
    ensure  => running,
    name    => $service,
    require => [
      File['/etc/cobbler/dhcp.template'],
      Package['dhcp'],
      Exec['cobblersync'],
    ],
  }

  file { '/etc/cobbler/dhcp.template':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['cobbler'],
    content => template($tmpl_dhcp_conf),
    notify  => Exec['cobblersync'],
  }

}
