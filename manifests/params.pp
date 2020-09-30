#
# = Class: cobbler::params
#
class cobbler::params {
  case $::osfamily {
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
      if (versioncmp($puppetversion,'6.0.0')>=0) {
        $puppetca_path           = '/opt/puppetlabs/bin/puppetserver'
      } else {
        $puppetca_path           = '/opt/puppetlabs/bin/puppet'
      }
      if (versioncmp($cobbler_version,'3.0.0')>=0) {
        $default_kickstart    = '/var/lib/cobbler/templates/default.ks'
        $kickstarts_path      = '/var/lib/cobbler/templates'
        $settings_template    = 'cobbler/settings.v3.erb'
        $dhcp_template        = 'cobbler/dhcp.template.v3.erb'
        $http_config_template = 'cobbler/cobbler.conf.v3.erb'
      } else {
        $default_kickstart    = '/var/lib/cobbler/kickstarts/default.ks'
        $kickstarts_path      = '/var/lib/cobbler/kickstarts'
        $settings_template    = 'cobbler/settings.erb'
        $dhcp_template        = 'cobbler/dhcp.template.erb'
        $http_config_template = 'cobbler/cobbler.conf.erb'
      }
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
      if (versioncmp($puppetversion,'6.0.0')>=0) {
        $puppetca_path           = '/opt/puppetlabs/bin/puppetserver'
      } else {
        $puppetca_path           = '/opt/puppetlabs/bin/puppet'
      }
      if (versioncmp($cobbler_version,'3.0.0')>=0) {
        $default_kickstart    = '/var/lib/cobbler/templates/ubuntu-server.preseed'
        $kickstarts_path      = '/var/lib/cobbler/templates'
        $settings_template    = 'cobbler/settings.v3.erb'
        $dhcp_template        = 'cobbler/dhcp.template.v3.erb'
        $http_config_template = 'cobbler/cobbler.conf.v3.erb'
      } else {
        $default_kickstart    = '/var/lib/cobbler/kickstarts/ubuntu-server.preseed'
        $kickstarts_path      = '/var/lib/cobbler/kickstarts'
        $settings_template    = 'cobbler/settings.erb'
        $dhcp_template        = 'cobbler/dhcp.template.erb'
        $http_config_template = 'cobbler/cobbler.conf.erb'
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} currently only supports osfamily RedHat")
    }
  }

}
