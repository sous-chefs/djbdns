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

- Ubuntu
- Debian
- RHEL

It may work with or without modification on other platforms, particularly using the `source` install method.

## Chef

- Chef 14+

## Cookbooks

- build-essential - for compiling the source.
- ucspi-tcp - `tcpserver` is used by the axfr recipe.
- runit - for setting up the services.

## Attributes

- `node['djbdns']['tinydns_ipaddress']` - listen address for public facing tinydns server
- `node['djbdns']['tinydns_internal_ipaddress']` - listen address for internal tinydns server
- `node['djbdns']['public_dnscache_ipaddress']` - listen address for public DNS cache
- `node['djbdns']['axfrdns_ipaddress']` - listen address for axfrdns
- `node['djbdns']['public_dnscache_allowed_networks']` - subnets that are allowed to talk to the dnscache.
- `node['djbdns']['tinydns_internal_resolved_domain']` - default domain this tinydns serves
- `node['djbdns']['tinydns_internal_resolved_reverse_domains']` - default in-addr.arpa domains this tinydns serves
- `node['djbdns']['axfrdns_dir']` - default location of the axfrdns service and configuration, default `/etc/djbdns/axfrdns`
- `node['djbdns']['tinydns_dir']` - default location of the tinydns service and configuration, default `/etc/djbdns/tinydns`
- `node['djbdns']['tinydns_internal_dir']` - default location of the tinydns internal service and configuration, default `/etc/djbdns/tinydns_internal`
- `node['djbdns']['public_dnscache_dir']` - default location of the public dnscache service and configuration, default `/etc/djbdns/public-dnscache`
- `node['djbdns']['bin_dir']` - default location where binaries will be stored.
- `node['djbdns']['axfrdns_uid']` - default uid for the axfrdns user
- `node['djbdns']['dnscache_uid']` - default uid for the dnscache user
- `node['djbdns']['dnslog_uid']` - default uid for the dnslog user
- `node['djbdns']['tinydns_uid']` - default uid for the tinydns user
- `node['djbdns']['package_name']` - name of the djbdns package. this shouldn't be changed most of the time, but may be necessary to use the [Debian fork](http://en.wikipedia.org/wiki/Dbndns), `dbndns`.
- `node['djbdns']['install_method']` - method used to install djbdns, can be `package`, or `source`.

## Resources

## djbdns_rr

Adds a resource record for the specified FQDN.

### Actions

- `:add`: Creates a new entry in the tinydns data file with the `add-X` scripts in the tinydns root directory.

### Attribute Parameters

- `fqdn`: name attribute. specifies the fully qualified domain name of the record.
- `ip`: ip address for the record.
- `type`: specifies the type of entry. valid types are: alias, alias6, childns, host, host6, mx, and ns. default is `host`.
- `cwd`: current working directory where the add scripts and data files must be located. default is the node attribute `djbdns[:tinydns_internal_dir]`, usually `/etc/djbdns/tinydns-internal`.

### Example

```ruby
djbdns_rr 'www.example.com' do
  ip '192.168.0.100'
  type 'host'
  action :add
  notifies :run, 'execute[build-tinydns-internal-data]'
end
```

(The resource `execute[build-tinydns-internal-data]` should run a `make` in the tinydns root directory (aka cwd).

## Recipes

## default

The default recipe installs djbdns software from package where available, otherwise installs from source. It also sets up the users that will run the djbdns services using the UID's specified by the attributes above. The service type to use is selected based on platform.

The default recipe attempts to install djbdns on as many platforms as possible. It tries to determine the platform's installation method:

- Debian will install from packages
- All other distributions will install from source.

Service specific users will be created as system users:

- dnscache
- dnslog
- tinydns

## axfr

Creates the axfrdns user and sets up the axfrdns service.

## cache

Sets up a local DNS caching server.

## internal_server

Sets up a server to be an internal nameserver. To modify resource records in the environment, modify the tinydns-internal-data.erb template, or create entries in a data bag named `djbdns`, and an item named after the domain, with underscores instead of spaces. Example structure of the data bag:

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

## server

Sets up a server to be a public nameserver. To modify resource records in the environment, modify the tinydns-data.erb template. The recipe does not yet use the data bag per `internal_server` above, but will in a future release.

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
