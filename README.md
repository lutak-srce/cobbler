# cobbler

[![License](https://img.shields.io/github/license/voxpupuli/puppet-rabbitmq.svg)](https://github.com/lutak-srce/cobbler/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/lutak-srce/cobbler.svg?branch=master)](https://travis-ci.org/lutak-srce/cobbler)

## Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with cobbler](#setup)
    * [What the module affects](#what-the-module-affects)
    * [Getting started with cobbler](#getting-started-with-cobbler)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Configure Cobbler global options](#configure-cobbler-global-options)
    * [Cobbler distro](#cobbler-distro)
    * [Cobbler repo](#cobbler-repo)
    * [Cobbler profile](#cobbler-profile)
    * [Cobbler system](#cobbler-system)
5. [Limitations - OS compatibility, etc.](#limitations)
    * [RHEL/CentOS](#rhelcentos)
    * [SELinux](#selinux)
6. [Development - Guide for contributing to the module](#development)
    * [Authors](#authors)

## Overview

This module manages [Cobbler](https://cobbler.github.io/).

Cobbler is a Linux installation server that allows for rapid setup of network
installation environments.

## Module Description

The Cobbler module provides a simplified way of setting up Cobbler and
managing internal Cobbler resources like `distro`, `profile` and `system`.
This allows admin to forget long and cumbersome cobbler CLI commands with
dozens of switches and options.

## Setup

### What the module affects

* cobbler package
* cobbler configuration files
* cobbler service
* cobbler's internal database records (distro, repo, profile, system)

### Getting started with cobbler

To install and configure Cobbler with the default parameters, declare the
`cobbler` class:

```puppet
include ::cobbler
```

To set up [Cobbler Web User Interface](http://cobbler.github.io/manuals/2.8.0/5_-_Web_Interface.html):

```puppet
include ::cobbler::web
```

## Usage

### Configure Cobbler global options

Cobbler defaults are determined depending on operating system. Module will
install `cobbler`, `tftp` and `syslinux`. It will use
[Apache module](https://github.com/puppetlabs/puppetlabs-apache)
to set up Apache `httpd` with `mod_wsgi`, which will serve `cobbler` and
`/distros` context in Apache.
When declaring the cobbler class, you can control many parameters relating
to the package and service, path for storing distributions, DHCP options,
etc:

```puppet
class cobbler {
  distro_path    => '/data/distro',
  manage_dhcp    => True,
  server_ip      => '10.100.0.111',
  next_server_ip => '10.100.0.111',
  purge_profile  => True,
  purge_system   => True,
}
```

### Cobbler distro

[Distro](https://cobbler.github.io/manuals/2.8.0/3/1/1_-_Distros.html) is an
object in Cobbler representing Linux distribution, with its own kernel,
installation and packages.

You can easily add distros to your Cobbler installation just by specifying
download link of ISO image and distro name:

```puppet
cobbler::add_distro { 'CentOS-6.5-x86_64':
  arch    => 'x86_64',
  isolink => 'http://mi.mirror.garr.it/mirrors/CentOS/6.5/isos/x86_64/CentOS-6.5-x86_64-bin-DVD1.iso',
}
```

If you want to use 'cobbler import' style, you can add a distro other way:

```puppet
cobblerdistro { 'SL-6.5-x86_64':
  ensure  => present,
  path    => '/distro/SL64/x86_64/os',
  ks_meta => {
   'tree' => 'http://repos.theory.phys.ucl.ac.uk/mirrors/SL/6.5/x86_64/os',
  },
}
```

`ks_meta` parameter's 'tree' value is used as `--available-as` option.

### Cobbler repo

[Repo](https://cobbler.github.io/manuals/2.8.0/3/1/5_-_Repos.html) is a
Cobbler object representing a distribution package repository (for
example yum repository).

If you wish to mirror additional repositories for your kickstart
installations, it's as easy as:

```puppet
cobblerrepo { 'PuppetLabs-6-x86_64-deps':
  ensure         => present,
  arch           => 'x86_64',
  mirror         => 'http://yum.puppetlabs.com/el/6/dependencies/x86_64',
  mirror_locally => false,
  priority       => 99,
  require        => [ Service[$cobbler::service_name], Service[$cobbler::apache_service] ],
}
```

### Cobbler profile

[Profile](https://cobbler.github.io/manuals/2.8.0/3/1/2_-_Profiles_and_Sub-Profiles.html)
is a Cobbler object representing a pre-configured set of distro/repos/settings for
kickstarting a node.

Simple profile definition looks like:

```puppet
cobblerprofile { 'CentOS-6.5-x86_64':
  ensure      => present,
  distro      => 'CentOS-6.5-x86_64',
  nameservers => $cobbler::nameservers,
  repos       => ['PuppetLabs-6-x86_64-deps', 'PuppetLabs-6-x86_64-products' ],
  kickstart   => '/somepath/kickstarts/CentOS-6.5-x86_64-static.ks',
}
```

### Cobbler system

[System](https://cobbler.github.io/manuals/2.8.0/3/1/3_-_Systems.html) is a
Cobbler object that maps physical or virtual machine with the cobbler profile
which is assigned to run on it.

Typical definition looks like:

```puppet
cobblersystem { 'somehost':
  ensure     => present,
  profile    => 'CentOS-6.5-x86_64',
  interfaces => { 'eth0' => {
                    mac_address      => 'AA:BB:CC:DD:EE:F0',
                    interface_type   => 'bond_slave',
                    interface_master => 'bond0',
                    static           => true,
                    management       => true,
                  },
                  'eth1' => {
                    mac_address      => 'AA:BB:CC:DD:EE:F1',
                    interface_type   => 'bond_slave',
                    interface_master => 'bond0',
                    static           => true,
                  },
                  'bond0' => {
                    ip_address     => '192.168.1.210',
                    netmask        => '255.255.255.0',
                    static         => true,
                    interface_type => 'bond',
                    bonding_opts   => 'miimon=300 mode=1 primary=em1',
                  },
  },
  netboot    => true,
  gateway    => '192.168.1.1',
  hostname   => 'somehost.example.com',
  require    => Service[$cobbler::service_name],
}
```

## Limitations

This module was on:
* CentOS 6/7
* Ubuntu LTS 12.04/14.04

Module depends on:
* [apache](http://forge.puppetlabs.com/puppetlabs/apache)

### RHEL/CentOS

Ensure the [EPEL](https://fedoraproject.org/wiki/EPEL) repo (or another repo
containing a suitable Cobbler version) is present.

### SELinux

This module is not tested on a system with SELinux in `enforcing` mode.
Please set the SELinux to `permissive`.

## Development

This module is maintained by Lutak Srce. Lutak Srce welcomes new contributions
to this module, especially those  that include documentation and rspec tests.
We are happy to provide guidance if necessary.

Please see [CONTRIBUTING](CONTRIBUTING.md) for more details.

### Authors

* jsosic (jsosic@gmail.com)
* Lutak Srce team
