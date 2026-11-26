# djbdns_axfrdns

Configures and starts an axfrdns service under runit.

## Actions

| Action    | Description                       |
|-----------|-----------------------------------|
| `:create` | Creates and starts the service    |
| `:delete` | Stops and removes service content |

## Properties

| Property            | Type    | Default              | Description                 |
|---------------------|---------|----------------------|-----------------------------|
| `service_name`      | String  | name property        | Runit service name          |
| `directory`         | String  | under base dir       | Service directory           |
| `tinydns_directory` | String  | `/etc/djbdns/tinydns`| tinydns service directory   |
| `ipaddress`         | String  | `127.0.0.1`          | Listen address              |
| `axfrdns_uid`       | Integer | `9996`               | UID for the `axfrdns` user  |

This resource also accepts common install properties from `djbdns_install`.

## Examples

```ruby
djbdns_axfrdns 'axfrdns' do
  tinydns_directory '/etc/djbdns/tinydns'
  ipaddress '127.0.0.1'
  action :create
end
```
