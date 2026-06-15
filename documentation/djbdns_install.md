# djbdns_install

Installs djbdns from source or from a distribution package and creates the shared service users.

## Actions

| Action     | Description                              |
|------------|------------------------------------------|
| `:install` | Installs djbdns and creates base users   |
| `:remove`  | Removes package or source-installed bins |

## Properties

| Property          | Type        | Default       | Description                     |
|-------------------|-------------|---------------|---------------------------------|
| `install_method`  | String      | platform lazy | `source` or `package`           |
| `package_name`    | String      | `djbdns`      | Package to install              |
| `bin_dir`         | String, nil | derived       | Binary directory override       |
| `base_dir`        | String      | `/etc/djbdns` | Base configuration directory    |
| `source_url`      | String      | upstream URL  | Source tarball URL              |
| `source_checksum` | String, nil | `nil`         | Optional source checksum        |
| `dnscache_uid`    | Integer     | `9997`        | UID for the `dnscache` user     |
| `dnslog_uid`      | Integer     | `9998`        | UID for the `dnslog` user       |
| `tinydns_uid`     | Integer     | `9999`        | UID for the `tinydns` user      |

## Examples

```ruby
djbdns_install 'default' do
  install_method 'source'
  action :install
end
```
