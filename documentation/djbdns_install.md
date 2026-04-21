# djbdns_install

Installs djbdns and creates the base service accounts and directories used by the higher-level service resources.

## Actions

| Action    | Description                                                           |
|-----------|-----------------------------------------------------------------------|
| `:create` | Installs djbdns and bootstraps shared users and directories (default) |

## Properties

| Property         | Type    | Default                                        | Description                          |
|------------------|---------|------------------------------------------------|--------------------------------------|
| `instance_name`  | String  | name property                                  | Resource identity                    |
| `install_method` | String  | platform-dependent                             | Install via `package` or `source`    |
| `package_name`   | String  | `'djbdns'`                                     | Package name for package installs    |
| `source_url`     | String  | `'https://cr.yp.to/djbdns/djbdns-1.05.tar.gz'` | Upstream source tarball              |
| `bin_dir`        | String  | derived from `install_method`                  | Install location for djbdns binaries |
| `dnscache_uid`   | Integer | `9997`                                         | UID for the `dnscache` account       |
| `dnslog_uid`     | Integer | `9998`                                         | UID for the `dnslog` account         |
| `tinydns_uid`    | Integer | `9999`                                         | UID for the `tinydns` account        |

## Examples

```ruby
djbdns_install 'default'
```

```ruby
djbdns_install 'source-bootstrap' do
  install_method 'source'
  bin_dir '/usr/local/bin'
end
```
