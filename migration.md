# Migration Guide

This release removes the legacy recipe and node-attribute API. Use the cookbook resources directly from wrapper cookbooks or roles instead of adding `djbdns::default`, `djbdns::server`, `djbdns::cache`, `djbdns::internal_server`, or `djbdns::axfr` to a run list.

## Recipe Mapping

| Removed recipe | Resource replacement |
|----------------|----------------------|
| `djbdns::default` | `djbdns_install` |
| `djbdns::server` | `djbdns_server` |
| `djbdns::cache` | `djbdns_cache` |
| `djbdns::internal_server` | `djbdns_internal_server` |
| `djbdns::axfr` | `djbdns_axfr` |

## Attribute Mapping

Node attributes under `node['djbdns']` are now explicit resource properties.

| Removed attribute | Resource property |
|-------------------|-------------------|
| `install_method` | `install_method` |
| `package_name` | `package_name` |
| `bin_dir` | `bin_dir` |
| `tinydns_ipaddress` | `djbdns_server.listen_ip` |
| `tinydns_internal_ipaddress` | `djbdns_internal_server.zone_ip` |
| `public_dnscache_ipaddress` | `djbdns_cache.listen_ip` |
| `axfrdns_ipaddress` | `djbdns_axfr.listen_ip` |
| `public_dnscache_allowed_networks` | `djbdns_cache.allowed_networks` |
| `tinydns_internal_resolved_domain` | `djbdns_cache.resolved_domain` |
| `tinydns_internal_resolved_reverse_domains` | `djbdns_cache.resolved_reverse_domains` |
| `axfrdns_dir` | `djbdns_axfr.service_dir` |
| `tinydns_dir` | `djbdns_server.service_dir` |
| `tinydns_internal_dir` | `djbdns_internal_server.service_dir` |
| `public_dnscache_dir` | `djbdns_cache.service_dir` |
| `axfrdns_uid` | `djbdns_axfr.axfrdns_uid` |
| `dnscache_uid` | `dnscache_uid` on install and service resources |
| `dnslog_uid` | `dnslog_uid` on install and service resources |
| `tinydns_uid` | `tinydns_uid` on install and service resources |

## Example

```ruby
djbdns_install 'default' do
  install_method 'source'
end

djbdns_server 'tinydns' do
  manage_install false
  listen_ip '127.0.0.1'
  domain 'example.test'
end

djbdns_cache 'public-dnscache' do
  manage_install false
  listen_ip '10.0.2.15'
  allowed_networks ['10.0']
  resolved_domain 'example.test'
end
```

The test cookbook under `test/cookbooks/test/recipes/` shows the migrated wrapper usage for the default, source, internal server, and AXFR integration suites.
