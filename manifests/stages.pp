## Wrapper class.  This will ensure all the auth stuff is managed before the
## file.  The file attempts to be owned by a user that's in LDAP, which isn't
## a valid user until the auth stuff is managed.
##
## This particular example uses runstages and demonstrates that even those are
## susceptible for this behavior of nsswitch.
class nssweird::stages {

  ## Create a runstage that is enforced before 'main' - the default stage.
  stage { 'pre':
    before => Stage['main'],
  }

  ## Throw the auth stuff into the 'pre' stage so that everything there is
  ## managed before everything else.
  class { 'nssweird::auth':
    stage => 'pre',
  }

  ## The user 'bob' is in LDAP and not available during our first Puppet run -
  ## before LDAP is configured.
  ## This is in the default 'main' stage.
  file { '/tmp/foo':
    ensure => 'file',
    owner  => 'bob',
    require => Class['nssweird::auth'],
  }

}
