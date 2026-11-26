# djbdns_tinydns

Configures and starts a tinydns service under runit.

## Actions

| Action    | Description                       |
|-----------|-----------------------------------|
| `:create` | Creates and starts the service    |
| `:delete` | Stops and removes service content |

## Properties

| Property             | Type        | Default       | Description                    |
|----------------------|-------------|---------------|--------------------------------|
| `service_name`       | String      | name property | Runit service name             |
| `directory`          | String      | under base dir| Service directory              |
| `ipaddress`          | String      | `127.0.0.1`   | Listen address                 |
| `domain`             | String      | node domain   | Zone domain for template data  |
| `internal`           | Boolean     | `false`       | Use internal tinydns template  |
| `data_bag`           | String, nil | `nil`         | Optional data bag for records  |
| `data_bag_item_name` | String, nil | domain-based  | Optional data bag item name    |

This resource also accepts common install properties from `djbdns_install`.

## Examples

```ruby
djbdns_tinydns 'tinydns' do
  domain 'example.test'
  ipaddress '127.0.0.1'
  action :create
end
```
