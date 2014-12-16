# puppet-nssweird

## Overview

This is a simple (crappy) module to demonstrate the behavior of `nsswitch`

Basically, if Puppet is managing `/etc/nsswitch.conf`, users/groups that are
made available by that management are not available during the same Puppet run.

### Scenario

Fresh box without any sort of authentication configuration.  We want to
configure this system as an LDAP client, which has users that we want to use
for other Puppet resources - e.g. a file resource owned by one of those LDAP
users.

Part of our Puppet manifest is managing `/etc/nsswitch.conf`, such as adding
an `ldap` entry to `passwd` or `groups`.

Even with proper relationships in Puppet (e.g. `require`), the users that are
made available by managing `/etc/nsswitch.conf` are _not_ available to us
during our Puppet run, which causes other resources to fail.

### Why

From the `nsswitch` [man page](http://linux.die.net/man/5/nsswitch.conf):

    Within each process that uses nsswitch.conf, the entire file is read only
    once. If the file is later changed, the process will continue using the old
    configuration.

This is just the nature of how `nsswitch` works, apparently. Solving this with
Puppet's resource relationships or ordering can't help us.  Puppet's
[run stages](https://docs.puppetlabs.com/puppet/latest/reference/lang_run_stages.html)
can't even help us.

### How to use this module

It assumes there's an LDAP server available. And some other things (this is
just a crappy example to see this thing).

Just declare the base class or the `nssweird::stages` class. Maybe something
like this:

```shell
puppet apply -e 'include nssweird` ; ls -l /tmp/foo
```

```shell
puppet apply -e 'include nssweird::stages' ; ls -l /tmp/foo
```

### Workarounds

__One__

Outside of a shitty script or something else using Puppet's `exec` resource,
I'm not sure.  This is undesirable, as it'd require any resource that depends
on one of those users/groups to be managed in a special, hacky way.

__Two__

A second Puppet run, unfortunately.  The first will have failures unless some,
possibly, serious work is done.

Perhaps an initial Puppet run that uses `--tags` to manage authentication?

For example:

```puppet
class 'myauthstuff' {
  tag preauth
}
```

Then:

```shell
puppet agent -t --tags preauth
```

### References

* [https://tickets.puppetlabs.com/browse/PUP-3204](https://tickets.puppetlabs.com/browse/PUP-3204)
* [https://projects.puppetlabs.com/issues/791#change-63870](https://projects.puppetlabs.com/issues/791#change-63870)
* [https://bugzilla.redhat.com/show_bug.cgi?id=132608](https://bugzilla.redhat.com/show_bug.cgi?id=132608)
