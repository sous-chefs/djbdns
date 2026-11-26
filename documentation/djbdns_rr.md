# djbdns_rr

Adds or removes a record using the tinydns `add-*` helpers.

## Actions

| Action    | Description                     |
|-----------|---------------------------------|
| `:add`    | Adds the record if absent       |
| `:remove` | Removes matching record entries |

## Properties

| Property | Type   | Default                            | Description                     |
|----------|--------|------------------------------------|---------------------------------|
| `fqdn`   | String | name property                      | Fully qualified record name     |
| `ip`     | String | required                           | Record IP address               |
| `type`   | String | `host`                             | alias, childns, host, mx, or ns |
| `cwd`    | String | `/etc/djbdns/tinydns-internal/root`| tinydns root directory          |

## Examples

```ruby
djbdns_rr 'www.example.test' do
  cwd '/etc/djbdns/tinydns/root'
  ip '192.0.2.10'
  type 'host'
  action :add
end
```
