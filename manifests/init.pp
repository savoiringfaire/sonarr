# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include sonarr
class sonarr (
  String $gpg_id = '0xA236C58F409091A18ACA53CBEBFF6B99D9B78493',
  String $gpg_keyserver = 'keyserver.ubuntu.com',
  Boolean $manage_gnupg = true,
  Boolean $manage_cacertificates = true,
){
  if ($manage_gnupg){
    package { 'gnupg': }
  }

  if ($manage_cacertificates) {
    package { 'ca-certificates': }
  }

  apt::key { 'sonarr':
    id     => $gpg_id,
    server => $gpg_keyserver,
  }

  apt::source { 'sonarr':
    comment  => 'Sonarr stable repository',
    location => 'http://apt.sonarr.tv/',
    release  => 'master',
    repos    => 'main',
    require  => [
      Package[gnupg],
      Package[ca-certificates],
      Apt::Key[sonarr]
    ],
  }

  package { 'nzbdrone':
    require => [
      Apt::Source[sonarr]
    ]
  }

  user { 'nzbdrone':
    ensure => present
  }

  file { '/lib/systemd/system/sonarr.service':
    ensure => file,
    content => template('sonarr/sonarr.service.erb')
  }

  service { 'sonarr':
    ensure => running,
    enable => true,
  }
}
