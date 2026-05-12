# djbdns_server

Creates the public tinydns service directory, renders the authoritative data file, and enables a native systemd service.

## Actions

| Action    | Description                                                 |
|-----------|-------------------------------------------------------------|
| `:create` | Configures and enables the public tinydns service (default) |
| `:delete` | Stops and disables the service, removes the systemd unit, and deletes the service directory |

## Properties

| Property               | Type        | Default                                        | Description                                              |
|------------------------|-------------|------------------------------------------------|----------------------------------------------------------|
| `service_name`         | String      | name property                                  | Service name, typically `tinydns`                        |
| `manage_install`       | Boolean     | `true`                                         | Also run `djbdns_install` before configuring the service |
| `install_method`       | String      | platform-dependent                             | Install via `package` or `source`                        |
| `package_name`         | String      | `'djbdns'`                                     | Package name for package installs                        |
| `source_url`           | String      | `'http://cr.yp.to/djbdns/djbdns-1.05.tar.gz'`  | Upstream source tarball                                  |
| `bin_dir`              | String      | derived from `install_method`                  | Location of djbdns binaries used by the systemd service  |
| `service_dir`          | String      | `'/etc/djbdns/tinydns'`                        | Service root directory                                   |
| `listen_ip`            | String      | `'127.0.0.1'`                                  | Address passed to `tinydns-conf`                         |
| `domain`               | String, nil | `node['domain']`                               | Domain rendered into `root/data`                         |
| `data_template_source` | String      | `'tinydns-data.erb'`                           | Template for the `root/data` file                        |
| `dnscache_uid`         | Integer     | `9997`                                         | UID for the `dnscache` account                           |
| `dnslog_uid`           | Integer     | `9998`                                         | UID for the `dnslog` account                             |
| `tinydns_uid`          | Integer     | `9999`                                         | UID for the `tinydns` account                            |

## Examples

```ruby
djbdns_server 'tinydns'
```

```ruby
djbdns_server 'tinydns' do
  manage_install false
  service_dir '/srv/tinydns'
  listen_ip '192.0.2.10'
  domain 'example.com'
end
```
