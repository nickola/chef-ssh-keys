Description
===========

Creates "authorized_keys" in user "~/.ssh" directory from a data bag.

Attributes
==========

For example, to create "authorized_keys" for user "root" from data bag user "user1", use:

    "ssh_keys": {
        "root": "user1"
    }

Usage
=====

Use knife to create a data bag for users:

    knife data bag create users

Create a user:

    knife data bag users user1
    {
      "id": "user1",
      "ssh_keys": "ssh-rsa AAAAB3Nz...yhCw== user1"
    }
