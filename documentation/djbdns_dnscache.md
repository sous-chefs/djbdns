# djbdns_dnscache

Configures and starts a dnscache service under runit.

## Actions

| Action    | Description                       |
|-----------|-----------------------------------|
| `:create` | Creates and starts the service    |
| `:delete` | Stops and removes service content |

## Properties

| Property                   | Type   | Default       | Description                    |
|----------------------------|--------|---------------|--------------------------------|
| `service_name`             | String | name property | Runit service name             |
| `directory`                | String | under base dir| Service directory              |
| `ipaddress`                | String | node IP       | Listen address                 |
| `allowed_networks`         | Array  | node network  | Networks allowed to query      |
| `resolved_domain`          | String | node domain   | Local domain server entry      |
| `resolved_reverse_domains` | Array  | RFC6303 list  | Reverse domains server entries |
| `cachesize`                | String | `1000000`     | dnscache cache size            |
| `datalimit`                | String | `3000000`     | dnscache data limit            |

This resource also accepts common install properties from `djbdns_install`.

## Examples

```ruby
djbdns_dnscache 'public-dnscache' do
  ipaddress '192.0.2.10'
  allowed_networks ['192.0']
  action :create
end
```
