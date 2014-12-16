## Wrapper class.  This will ensure all the auth stuff is managed before the
## file.  The file attempts to be owned by a user that's in LDAP, which isn't
## a valid user until the auth stuff is managed.
class nssweird {

  class { 'nssweird::auth': }

  ## The user 'bob' is in LDAP and not available during our first Puppet run -
  ## before LDAP is configured.
  file { '/tmp/foo':
    ensure => 'file',
    owner  => 'bob',
    require => Class['nssweird::auth'],
  }
}
