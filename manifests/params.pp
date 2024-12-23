#
# = Class: cobbler::params
#
class cobbler::params {
  case $facts['os']['family'] {
    'RedHat': {
      $service_name           = 'cobblerd'
      $package_name           = 'cobbler'
      $package_name_web       = 'cobbler-web'
      $tftpd_package          = 'tftp-server'
      $syslinux_package       = 'syslinux'
      $dhcp_package           = 'dhcp'
      $dhcp_version           = 'present'
      $dhcp_service           = 'dhcpd'
      $http_config_prefix     = '/etc/httpd/conf.d'
      $proxy_config_prefix    = '/etc/httpd/conf.d'
      $distro_path            = '/distro'
      $apache_service         = 'httpd'
      $default_kickstart      = '/var/lib/cobbler/kickstarts/default.ks'
    }
    'Debian': {
      $service_name        = 'cobbler'
      $package_name        = 'cobbler'
      $package_name_web    = 'cobbler-web'
      $tftpd_package       = 'tftpd-hpa'
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
      fail("Unsupported osfamily: ${facts['os']['family']} operatingsystem: ${facts['os']['name']}, module ${module_name} currently only supports osfamily RedHat")
    }
  }

}
