# djbdns_internal_server

Creates the internal tinydns service and supports either explicit record data or a data-bag/template fallback path.

## Actions

| Action    | Description                                                                                 |
| --------- | ------------------------------------------------------------------------------------------- |
| `:create` | Configures and enables the internal tinydns service (default)                               |
| `:delete` | Stops and disables the service, removes the systemd unit, and deletes the service directory |

## Properties

| Property               | Type           | Default                                        | Description                                              |
| ---------------------- | -------------- | ---------------------------------------------- | -------------------------------------------------------- |
| `service_name`         | String         | name property                                  | Service name, typically `tinydns-internal`               |
| `manage_install`       | Boolean        | `true`                                         | Also run `djbdns_install` before configuring the service |
| `install_method`       | String         | platform-dependent                             | Install via `package` or `source`                        |
| `package_name`         | String         | `'djbdns'`                                     | Package name for package installs                        |
| `source_url`           | String         | `'http://cr.yp.to/djbdns/djbdns-1.05.tar.gz'`  | Upstream source tarball                                  |
| `bin_dir`              | String         | derived from `install_method`                  | Location of djbdns binaries used by the systemd service  |
| `service_dir`          | String         | `'/etc/djbdns/tinydns-internal'`               | Service root directory                                   |
| `listen_ip`            | String         | `'127.0.0.1'`                                  | Address passed to `tinydns-conf`                         |
| `zone_domain`          | String         | `node['domain'] \|\| 'domain.local'`           | Domain rendered into the fallback template               |
| `zone_ip`              | String         | `'127.0.0.1'`                                  | IP rendered into the fallback template                   |
| `data_template_source` | String         | `'tinydns-internal-data.erb'`                  | Template used when no explicit records resolve           |
| `use_data_bag`         | Boolean        | `true`                                         | Attempt data-bag loading when `records` is empty         |
| `data_bag_name`        | String         | `'djbdns'`                                     | Data bag name for record loading                         |
| `data_bag_item_id`     | String or nil  | `zone_domain.tr('.', '_')`                     | Data bag item id for record loading                      |
| `records`              | Hash           | `{}`                                           | Explicit record map keyed by djbdns record type          |
| `dnscache_uid`         | Integer        | `9997`                                         | UID for the `dnscache` account                           |
| `dnslog_uid`           | Integer        | `9998`                                         | UID for the `dnslog` account                             |
| `tinydns_uid`          | Integer        | `9999`                                         | UID for the `tinydns` account                            |

## Examples

```ruby
djbdns_internal_server 'tinydns-internal' do
  use_data_bag false
  zone_domain 'int.example.test'
  zone_ip '192.0.2.20'
end
```

```ruby
djbdns_internal_server 'tinydns-internal' do
  manage_install false
  records(
    'host' => [
      { 'web1.int.example.test' => '192.0.2.10' },
    ]
  )
end
```
