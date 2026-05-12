# djbdns Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/djbdns.svg)](https://supermarket.chef.io/cookbooks/djbdns)
[![CI State](https://github.com/sous-chefs/djbdns/workflows/ci/badge.svg)](https://github.com/sous-chefs/djbdns/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Installs and configures Dan Bernstein's DNS tinydns, aka djbdns. Services are configured with native systemd units managed by Chef's built-in resources.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

## Platforms

The following platforms are supported via Test Kitchen.

* AlmaLinux 9
* CentOS Stream 9
* Debian 12
* Ubuntu 22.04
* Ubuntu 24.04

It may work with or without modification on other platforms, particularly using the `source` install method.

## Chef

* Chef 15.3+

## Cookbooks

* build-essential - for compiling the source.
* ucspi-tcp - `tcpserver` is used by the axfr recipe.

## Migration

This cookbook is resource-only. Legacy recipes and `node['djbdns']` attributes have been removed; see [migration.md](migration.md) for the breaking-change mapping.

## Resources

The public API is the custom resource surface:

* `djbdns_install` - installs djbdns and bootstraps shared users/directories.
* `djbdns_server` - configures the public tinydns service.
* `djbdns_internal_server` - configures the internal tinydns service with explicit records or data-bag/template inputs.
* `djbdns_cache` - configures the public dnscache service.
* `djbdns_axfr` - configures the axfrdns service that fronts an existing public tinydns directory.
* `djbdns_rr` - appends tinydns records inside an existing tinydns root.

Resource documentation lives under `documentation/`.

## djbdns_rr

Adds a resource record for the specified FQDN.

### Actions

* `:add`: Creates a new entry in the tinydns data file with the `add-X` scripts in the tinydns root directory.
* `:delete`: Removes matching entries from the tinydns data file.

### Properties

* `fqdn`: name attribute. specifies the fully qualified domain name of the record.
* `ip`: ip address for the record.
* `type`: specifies the type of entry. valid types are: alias, alias6, childns, host, host6, mx, and ns. default is `host`.
* `cwd`: current working directory where the add scripts and data files must be located. default is `/etc/djbdns/tinydns-internal/root`.

### Example

```ruby
djbdns_rr 'www.example.com' do
  ip '192.168.0.100'
  type 'host'
  action :add
  notifies :run, 'execute[build-tinydns-internal-data]'
end
```

The resource `execute[build-tinydns-internal-data]` should run `make` in the tinydns root directory.

## Data Bag Records

`djbdns_internal_server` supports explicit `records`, or a data-bag/template path using a `djbdns` data bag item named after the domain with underscores instead of spaces. Example structure:

```json
{
  "id": "int_example_com",
  "ns": [
    { "int.example.com": "192.168.0.5" },
    { "0.168.192.in-addr.arpa": "192.168.0.5" }
  ],
  "alias": [
    { "www.int.example.com": "192.168.0.100" }
  ],
  "host": [
    { "web1.int.example.com": "192.168.0.100" }
  ]
}
```

Aliases and hosts should be an array of hashes, each entry containing the fqdn as the key and the IP as the value. In this example 192.168.0.5 is the IP of the nameserver and is listed as authoritative for int.example.com and for reverse DNS for 192.168.0.x.

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.
![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
