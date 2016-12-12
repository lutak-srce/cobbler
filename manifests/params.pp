# Class: cobbler::params
#
#   The cobbler default configuration settings.
#
class cobbler::params {
  case $::osfamily {
    'RedHat': {
      $service_name           = 'cobblerd'
      $package_name           = 'cobbler'
      $package_name_web       = 'cobbler-web'
      $tftp_package           = 'tftp-server'
      $syslinux_package       = 'syslinux'
      $dhcp_package           = 'dhcp'
      $dhcp_version           = 'present'
      $dhcp_service           = 'dhcpd'
      $http_config_prefix     = '/etc/httpd/conf.d'
      $proxy_config_prefix    = '/etc/httpd/conf.d'
      $distro_path            = '/distro'
      $apache_service         = 'httpd'
      $file_proxy_cobbler_erb = "cobbler/proxy_cobbler.el${::operatingsystemmajrelease}.conf.erb"
      $default_kickstart      = '/var/lib/cobbler/kickstarts/default.ks'
    }
    'Debian': {
      $service_name        = 'cobbler'
      $package_name        = 'cobbler'
      $package_name_web    = 'cobbler-web'
      $tftp_package        = 'tftpd-hpa'
      $syslinux_package    = 'syslinux'
      $dhcp_package        = 'isc-dhcp-server'
      $dhcp_version        = 'present'
      $dhcp_service        = 'isc-dhcp-server'
      $http_config_prefix  = '/etc/apache2/conf.d'
      $proxy_config_prefix = '/etc/apache2/conf.d'
      $distro_path         = '/var/www/cobbler/ks_mirror'
      $apache_service      = 'apache2'
      $default_kickstart   = '/var/lib/cobbler/kickstarts/ubuntu-server.preseed'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} currently only supports osfamily RedHat")
    }
  }
  $package_ensure = 'present'

  # class containing all module dependencies
  $dependency_class = '::cobbler::dependency'

  # location of the cobbler web root
  $webroot = '/var/www/cobbler'

  # general settings
  $next_server_ip = $::ipaddress
  $server_ip      = $::ipaddress
  $nameservers    = '127.0.0.1'

  # default root password for kickstart files
  $defaultrootpw = 'bettergenerateityourself'

  # dhcp options
  $manage_dhcp        = 0
  $dhcp_option        = 'isc'
  $dhcp_interfaces    = 'eth0'
  $dhcp_subnets       = ''
  $dhcp_dynamic_range = 0

  # dns options
  $manage_dns = 0
  $dns_option = 'dnsmasq'

  # tftpd options
  $manage_tftpd = 1
  $tftpd_option = 'in_tftpd'

  # puppet integration setup
  $puppet_auto_setup                     = 1
  $sign_puppet_certs_automatically       = 1
  $remove_old_puppet_certs_automatically = 1

  # depends on apache
  # access, regulated through Proxy directive
  $allow_access = "${server_ip} ${::ipaddress} 127.0.0.1"

  # authorization
  $auth_module = 'authn_denyall'

}
