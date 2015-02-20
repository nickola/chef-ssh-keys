Description
===========

Creates `authorized_keys` in user `~/.ssh` directory from a data bag (encrypted data bag supported).

Attributes
==========

Expects `node[:ssh_keys]` to be an hash containing the user name as key and data bag user name as value.
Also, users can be defined by groups (see usage examples below).

See `attributes/default.rb` for additional attributes default values.

Usage
=====

Node configuration example to create `authorized_keys` for user `root` from data bag user `user1`:

    {
      "ssh_keys": {
        "root": "user1"
      },
      "run_list": [
        "recipe[ssh-keys]"
      ]
    }

Node configuration example to create `authorized_keys` for user `root` from data bag user `user1` and `user2`:

    {
      "ssh_keys": {
        "root": ["user1", "user2"]
      },
      "run_list": [
        "recipe[ssh-keys]"
      ]
    }

Node configuration example to create `authorized_keys` for user `root` from users of group `admin`:

    {
      "ssh_keys": {
        "root": {"groups": "admin"}
      },
      "run_list": [
        "recipe[ssh-keys]"
      ]
    }

Node configuration example to create `authorized_keys` for user `root` from data bag user `user1` and `user2`, and from users of groups `admin` and `operator`:

    {
      "ssh_keys": {
        "root": {"users": ["user1", "user2"], "groups": ["admin", "operator"]}
      },
      "run_list": [
        "recipe[ssh-keys]"
      ]
    }

Use knife to create a data bag for users:

    knife data bag create users

User data bag example (compatible with Chef [users cookbook](https://github.com/opscode-cookbooks/users)):

    knife data bag users user1
    {
      "id": "user1",
      "ssh_keys": "ssh-rsa AAAAB3Nz...yhCw== user1"
    }

    knife data bag users user2
    {
      "id": "user2",
      "ssh_keys": "ssh-rsa AAAAB3Nz...5D8F== user2"
    }

Cookbook URLs
=============

  - Chef Supermarket: https://supermarket.chef.io/cookbooks/ssh-keys
  - GitHub: https://github.com/nickola/chef-ssh-keys
  - Author: http://www.nickola.ru
