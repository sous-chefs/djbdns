# frozen_string_literal: true

include_recipe 'test::default'

djbdns_axfrdns 'axfrdns' do
  ipaddress '127.0.0.1'
  action :create
end

execute 'compile loopback AXFR fixture ACL' do
  command 'make tcp.cdb'
  cwd '/etc/djbdns/axfrdns'
  action :nothing
end

file '/etc/djbdns/axfrdns/tcp' do
  content "127.0.0.1:allow,AXFR=\"example.test\"\n:deny\n"
  notifies :run, 'execute[compile loopback AXFR fixture ACL]', :immediately
end
