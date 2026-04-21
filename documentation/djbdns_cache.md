# djbdns_cache

Creates the public dnscache service directory, manages allowed client networks, and enables the runit-backed cache service.

## Actions

| Action    | Description                                                  |
|-----------|--------------------------------------------------------------|
| `:create` | Configures and enables the public dnscache service (default) |

## Properties

| Property                   | Type    | Default                                        | Description                                              |
| -------------------------- | ------- | ---------------------------------------------- | -------------------------------------------------------- |
| `service_name`             | String  | name property                                  | Service name, typically `public-dnscache`                |
| `manage_install`           | Boolean | `true`                                         | Also run `djbdns_install` before configuring the service |
| `install_method`           | String  | platform-dependent                             | Install via `package` or `source`                        |
| `package_name`             | String  | `'djbdns'`                                     | Package name for package installs                        |
| `source_url`               | String  | `'https://cr.yp.to/djbdns/djbdns-1.05.tar.gz'` | Upstream source tarball                                  |
| `bin_dir`                  | String  | derived from `install_method`                  | Location of djbdns binaries used by runit                |
| `service_dir`              | String  | `'/etc/djbdns/public-dnscache'`                | Service root directory                                   |
| `listen_ip`                | String  | `node['ipaddress']`                            | Address passed to `dnscache-conf`                        |
| `allowed_networks`         | Array   | first two IP octets                            | Networks allowed to query the cache                      |
| `resolved_domain`          | String  | `node['domain'] \|\| 'domain.local'`           | Internal domain pinned to localhost                      |
| `resolved_reverse_domains` | Array   | RFC 6303-style defaults                        | Reverse zones pinned to localhost                        |
| `cache_size`               | String  | `'1000000'`                                    | dnscache `CACHESIZE` environment value                   |
| `data_limit`               | String  | `'3000000'`                                    | dnscache `DATALIMIT` environment value                   |
| `dnscache_uid`             | Integer | `9997`                                         | UID for the `dnscache` account                           |
| `dnslog_uid`               | Integer | `9998`                                         | UID for the `dnslog` account                             |
| `tinydns_uid`              | Integer | `9999`                                         | UID for the `tinydns` account                            |

## Examples

```ruby
djbdns_cache 'public-dnscache'
```

```ruby
djbdns_cache 'public-dnscache' do
  manage_install false
  listen_ip '192.0.2.53'
  allowed_networks %w(192.0 198.51)
end
```
