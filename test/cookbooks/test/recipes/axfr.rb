# frozen_string_literal: true

include_recipe 'test::default'

djbdns_axfrdns 'axfrdns' do
  ipaddress '127.0.0.1'
  action :create
end
