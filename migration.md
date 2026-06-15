# Migration

## Full Custom Resource Migration

This release removes the legacy root `recipes/` and `attributes/` public API. Use the custom resources directly from wrapper cookbooks or policy recipes.

## Recipe Mapping

| Legacy recipe              | Replacement resource                  |
|----------------------------|---------------------------------------|
| `djbdns::default`          | `djbdns_install`                      |
| `djbdns::server`           | `djbdns_tinydns`                      |
| `djbdns::internal_server`  | `djbdns_tinydns` with `internal true` |
| `djbdns::cache`            | `djbdns_dnscache`                     |
| `djbdns::axfr`             | `djbdns_axfrdns`                      |

## Attribute Mapping

Node attributes under `node['djbdns']` are now resource properties. For example, replace:

```ruby
node.default['djbdns']['tinydns_ipaddress'] = '127.0.0.1'
include_recipe 'djbdns::server'
```

with:

```ruby
djbdns_tinydns 'tinydns' do
  ipaddress '127.0.0.1'
  domain 'example.test'
  action :create
end
```

The test cookbook under `test/cookbooks/test/recipes/` contains complete examples for default, source, and AXFR service setups.
