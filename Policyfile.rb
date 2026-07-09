# frozen_string_literal: true

name 'djbdns'
default_source :supermarket

run_list 'djbdns::default'

cookbook 'djbdns', path: '.'
cookbook 'test', path: './test/fixtures/cookbooks/test'
