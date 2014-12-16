##
## From the nsswitch man page:
##   Within each process that uses nsswitch.conf, the entire file is read only
##   once. If the file is later changed, the process will continue using the
##   old configuration.
##
## References:
##   https://tickets.puppetlabs.com/browse/PUP-3204
##   https://projects.puppetlabs.com/issues/791#change-63870
##   https://bugzilla.redhat.com/show_bug.cgi?id=132608
##
class nssweird::auth {

  if $::osfamily != 'RedHat' {
    fail("${modulename} is only supported on RedHat")
  }

  package { 'nslcd':
    ensure => 'installed',
    name   => 'nss-pam-ldapd',
  }

  file { 'nslcd.conf':
    ensure => 'link',
    path   => '/etc/nslcd.conf',
    target => '/etc/ldap.conf',
  }

  file { 'ldap.conf':
    ensure => 'link',
    path   => '/etc/nslcd.conf',
  }

  file { 'nsswitch':
    ensure  => 'file',
    path    => '/etc/nsswitch.conf',
    source  => 'puppet:///modules/test/nsswitch.conf',
    require => [
      Package['nslcd'],
      File['ldap.conf']
    ],
  }

  service { 'nslcd':
    ensure  => 'running',
    require => File['nslcd.conf'],
  }

  ## Even nscd or caching can't save us here!
  service { 'nscd':
    ensure  => 'running',
    require => Service['nslcd'],
  }

}
