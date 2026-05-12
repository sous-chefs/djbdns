# djbdns_axfr

Creates the axfrdns service directory, bootstraps the `axfrdns` user, and enables a native systemd zone transfer service.

## Actions

| Action    | Description                                          |
|-----------|------------------------------------------------------|
| `:create` | Configures and enables the axfrdns service (default) |
| `:delete` | Stops and disables the service, removes the systemd unit, deletes the service directory, and removes the `axfrdns` user |

## Properties

| Property           | Type    | Default                                        | Description                                              |
|--------------------|---------|------------------------------------------------|----------------------------------------------------------|
| `service_name`     | String  | name property                                  | Service name, typically `axfrdns`                        |
| `manage_install`   | Boolean | `true`                                         | Also run `djbdns_install` before configuring the service |
| `install_method`   | String  | platform-dependent                             | Install via `package` or `source`                        |
| `package_name`     | String  | `'djbdns'`                                     | Package name for package installs                        |
| `source_url`       | String  | `'http://cr.yp.to/djbdns/djbdns-1.05.tar.gz'`  | Upstream source tarball                                  |
| `bin_dir`          | String  | derived from `install_method`                  | Location of djbdns binaries used by the systemd service  |
| `service_dir`      | String  | `'/etc/djbdns/axfrdns'`                        | Service root directory                                   |
| `listen_ip`        | String  | `'127.0.0.1'`                                  | Address passed to `axfrdns-conf`                         |
| `tinydns_dir`      | String  | `'/etc/djbdns/tinydns'`                        | Public tinydns directory used by axfrdns                 |
| `axfrdns_uid`      | Integer | `9996`                                         | UID for the `axfrdns` account                            |
| `dnscache_uid`     | Integer | `9997`                                         | UID for the `dnscache` account                           |
| `dnslog_uid`       | Integer | `9998`                                         | UID for the `dnslog` account                             |
| `tinydns_uid`      | Integer | `9999`                                         | UID for the `tinydns` account                            |

## Examples

```ruby
djbdns_axfr 'axfrdns'
```

```ruby
djbdns_axfr 'axfrdns' do
  manage_install false
  service_dir '/srv/axfrdns'
  tinydns_dir '/srv/tinydns'
  listen_ip '192.0.2.53'
end
```
