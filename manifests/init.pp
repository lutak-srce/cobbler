#
# = Class: cobbler
#
class cobbler (
  $service_name            = $::cobbler::params::service_name,
  $package_name            = $::cobbler::params::package_name,
  $package_ensure          = 'present',
  $distro_path             = $::cobbler::params::distro_path,
  $server_ip               = $::ipaddress,
  $next_server_ip          = $::ipaddress,
  $nameservers             = [ '8.8.8.8', '8.8.4.4' ],
  $puppet_auto_setup       = 0,
  $puppetca_path           = '/opt/puppetlabs/bin/puppet',
  $sign_puppet_certs       = 0,
  $remove_old_puppet_certs = 0,
  $manage_dhcp             = '1',
  $dhcp_option             = 'isc',
  $dhcp_package            = $::cobbler::params::dhcp_package,
  $dhcp_service            = $::cobbler::params::dhcp_service,
  $dhcp_template           = 'cobbler/dhcp.template.erb',
  $dhcp_interfaces         = [ 'eth0' ],
  $dhcp_subnets            = [],
  $dhcp_nameservers        = [ '8.8.8.8', '8.8.4.4' ],
  $dhcp_dynamic_range      = false,
  $manage_dns              = '0',
  $dns_option              = 'dnsmasq',
  $manage_tftpd            = '1',
  $tftpd_package           = $::cobbler::params::tftpd_package,
  $tftpd_option            = 'in_tftpd',
  $syslinux_package        = $::cobbler::params::syslinux_package,
  $defaultrootpw           = 'bettergenerateityourself',
  $apache_service          = $::cobbler::params::apache_service,
  $file_proxy_cobbler_erb  = 'cobbler/proxy_cobbler.conf.erb',
  $allow_access            = "${server_ip} ${::ipaddress} 127.0.0.1",
  $purge_distro            = false,
  $purge_repo              = false,
  $purge_profile           = false,
  $purge_system            = false,
  $default_kickstart       = $::cobbler::params::default_kickstart,
  $kickstarts_path         = '/var/lib/cobbler/kickstarts',
  $webroot                 = '/var/www/cobbler',
  $auth_module             = 'authn_denyall',
  $create_resources        = false,
  $dependency_class        = '::cobbler::dependency',
  $my_class                = undef,
  $noops                   = undef,
) inherits cobbler::params {

  # include dependencies
  if $::cobbler::dependency_class {
    include $::cobbler::dependency_class
  }

  # install section
  Package {
    ensure => $package_ensure,
    noop   => $noops,
  }

  package { 'tftp-server': name => $tftpd_package    }
  package { 'syslinux':    name => $syslinux_package }

  package { 'cobbler':
    name    => $package_name,
    require => Package['tftp-server','syslinux'],
  }

  service { 'cobbler':
    ensure  => running,
    name    => $service_name,
    enable  => true,
    require => Package['cobbler'],
    noop    => $noops,
  }

  # file defaults
  File {
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    noop   => $noops,
  }

  file { "${::cobbler::params::proxy_config_prefix}/proxy_cobbler.conf":
    content => template($file_proxy_cobbler_erb),
    notify  => Service['httpd'],
  }

  file { $distro_path :
    ensure => directory,
    mode   => '0755',
  }

  file { '/var/lib/cobbler/kickstarts':
    ensure => directory,
    path   => $kickstarts_path,
    mode   => '0755',
  }

  file { '/etc/cobbler/settings':
    content => template('cobbler/settings.erb'),
    require => Package['cobbler'],
    notify  => Service['cobbler'],
  }

  file { '/etc/cobbler/modules.conf':
    content => template('cobbler/modules.conf.erb'),
    require => Package['cobbler'],
    notify  => Service['cobbler'],
  }

  file { "${::cobbler::params::http_config_prefix}/distros.conf": content => template('cobbler/distros.conf.erb'), }
  file { "${::cobbler::params::http_config_prefix}/cobbler.conf": content => template('cobbler/cobbler.conf.erb'), }

  # cobbler sync command
  exec { 'cobblersync':
    command     => '/usr/bin/cobbler sync',
    refreshonly => true,
    require     => [ Service['cobbler'], Service['httpd'] ],
  }

  # resource defaults
  resources { 'cobblerdistro':
    purge   => $purge_distro,
    require => [ Service['cobbler'], Service['httpd'] ],
    noop    => $noops,
  }
  resources { 'cobblerrepo':
    purge   => $purge_repo,
    require => [ Service['cobbler'], Service['httpd'] ],
    noop    => $noops,
  }
  resources { 'cobblerprofile':
    purge   => $purge_profile,
    require => [ Service['cobbler'], Service['httpd'] ],
    noop    => $noops,
  }
  resources { 'cobblersystem':
    purge   => $purge_system,
    require => [ Service['cobbler'], Service['httpd'] ],
    noop    => $noops,
  }

  # create resources from hiera
  if $create_resources {
    create_resources(cobblerdistro,  hiera_hash('cobbler::distros',  {}) )
    create_resources(cobblerrepo,    hiera_hash('cobbler::repos',    {}) )
    create_resources(cobblerprofile, hiera_hash('cobbler::profiles', {}) )
    create_resources(cobblersystem,  hiera_hash('cobbler::systems',  {}) )
  }

  # include ISC DHCP only if we choose manage_dhcp
  if ( $manage_dhcp == '1' ) and ( $dhcp_option == 'isc' ) {
    class { '::cobbler::dhcp':
      package       => $dhcp_package,
      service       => $dhcp_service,
      dhcp_template => $dhcp_template,
      nameservers   => $dhcp_nameservers,
      interfaces    => $dhcp_interfaces,
      subnets       => $dhcp_subnets,
      dynamic_range => $dhcp_dynamic_range,
    }
  }

  # logrotate script
  file { '/etc/logrotate.d/cobbler':
    source => 'puppet:///modules/cobbler/logrotate',
  }
}
# vi:nowrap:
