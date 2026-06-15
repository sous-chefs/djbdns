# frozen_string_literal: true

require 'spec_helper'

describe Djbdns::Helpers do
  let(:helper_class) do
    Class.new do
      include Djbdns::Helpers

      attr_accessor :node

      def platform?(name)
        node['platform'] == name
      end

      def platform_family?(family)
        node['platform_family'] == family
      end
    end
  end

  let(:helper) { helper_class.new }

  before do
    helper.node = {
      'platform' => 'ubuntu',
      'platform_family' => 'debian',
      'platform_version' => '24.04',
      'ipaddress' => '192.168.10.20',
      'domain' => 'example.test',
    }
  end

  it 'defaults current platforms to source installs' do
    expect(helper.default_install_method).to eq('source')
  end

  it 'keeps the legacy package default for old Ubuntu' do
    helper.node['platform_version'] = '16.04'

    expect(helper.default_install_method).to eq('package')
  end

  it 'derives allowed networks from the node ipaddress' do
    expect(helper.default_allowed_networks).to eq(['192.168'])
  end

  it 'treats /etc/service links as enabled runit services' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/etc/service/tinydns').and_return(true)

    expect(helper.runit_service_enabled?('tinydns')).to be true
  end

  it 'treats runsvdir links as enabled runit services' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/etc/service/tinydns').and_return(false)
    allow(File).to receive(:exist?).with('/etc/runit/runsvdir/default/tinydns').and_return(true)

    expect(helper.runit_service_enabled?('tinydns')).to be true
  end
end
