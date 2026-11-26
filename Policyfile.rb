# frozen_string_literal: true

name 'djbdns'
default_source :supermarket

run_list 'test::default'

cookbook 'djbdns', path: '.'
cookbook 'test', path: './test/cookbooks/test'

named_run_list :default, 'test::default'
named_run_list :source, 'test::source'
named_run_list :axfr, 'test::axfr'
