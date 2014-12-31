file '/etc/resolv.conf' do
  manage_symlink_source true
  content "nameserver #{node['ipaddress']}"
end
