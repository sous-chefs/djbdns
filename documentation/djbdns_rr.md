# djbdns_rr

Adds tinydns records by running the generated `add-*` helper scripts in an existing tinydns root directory.

## Actions

| Action | Description                                                             |
|--------|-------------------------------------------------------------------------|
| `:add` | Adds a tinydns resource record when it does not already exist (default) |

## Properties

| Property | Type   | Default                                       | Description                                                                        |
|----------|--------|-----------------------------------------------|------------------------------------------------------------------------------------|
| `fqdn`   | String | name property                                 | Fully qualified domain name to manage                                              |
| `ip`     | String | required                                      | IP address for the record                                                          |
| `type`   | String | `'host'`                                      | Record helper to run: `alias`, `alias6`, `childns`, `host`, `host6`, `mx`, or `ns` |
| `cwd`    | String | `node['djbdns']['tinydns_internal_dir']/root` | Tinydns root directory containing `data` and `add-*` helpers                       |

## Examples

```ruby
djbdns_rr 'www.example.com' do
  ip '192.0.2.10'
end
```

```ruby
djbdns_rr 'ns.example.com' do
  ip '192.0.2.53'
  type 'ns'
  cwd '/etc/djbdns/tinydns-internal/root'
end
```
