# djbdns Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/djbdns.svg)](https://supermarket.chef.io/cookbooks/djbdns)
[![CI State](https://github.com/sous-chefs/djbdns/workflows/ci/badge.svg)](https://github.com/sous-chefs/djbdns/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Installs and configures Dan Bernstein's DNS tinydns, aka djbdns. Services are configured to start up under runit.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

## Platforms

The following platforms are supported via test kitchen.

- AlmaLinux
- Amazon Linux
- CentOS Stream
- Debian
- Fedora
- Oracle Linux
- Red Hat Enterprise Linux
- Rocky Linux
- Ubuntu

See [LIMITATIONS.md](LIMITATIONS.md) for package and source installation notes.

## Chef

- Chef 15.3+

## Cookbooks

- runit - for setting up the services.

## Migration

This cookbook now exposes custom resources instead of root recipes and node attributes. See [migration.md](migration.md) for the breaking migration guide.

## Resources

* [djbdns_install](documentation/djbdns_install.md)
* [djbdns_tinydns](documentation/djbdns_tinydns.md)
* [djbdns_dnscache](documentation/djbdns_dnscache.md)
* [djbdns_axfrdns](documentation/djbdns_axfrdns.md)
* [djbdns_rr](documentation/djbdns_rr.md)

## Examples

### Authoritative tinydns

```ruby
djbdns_tinydns 'tinydns' do
  domain 'example.test'
  ipaddress '127.0.0.1'
  action :create
end
```

### DNS cache

```ruby
djbdns_dnscache 'public-dnscache' do
  ipaddress '192.0.2.10'
  allowed_networks ['192.0']
  action :create
end
```

### Internal tinydns from a data bag

Create entries in a data bag named `djbdns`, and an item named after the domain, with underscores instead of spaces. Example structure of the data bag:

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

Aliases and hosts should be an array of hashes, each entry containing the fqdn as the key and the IP as the value. In this example 192.168.0.5 is the IP of the nameserver and we're listing it as authoritative for int.example.com and for reverse DNS for 192.168.0.x.

```ruby
djbdns_tinydns 'tinydns-internal' do
  internal true
  data_bag 'djbdns'
  domain 'int.example.com'
  action :create
end
```

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
