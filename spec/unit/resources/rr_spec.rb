# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_rr' do
  step_into :djbdns_rr
  platform 'ubuntu', '22.04'

  context 'with a missing record' do
    recipe do
      djbdns_rr 'www.example.test' do
        cwd '/etc/djbdns/tinydns-internal/root'
        ip '192.0.2.10'
        type 'host'
      end
    end

    before do
      allow(::File).to receive(:exist?).and_call_original
      allow(::File).to receive(:exist?).with('/etc/djbdns/tinydns-internal/root/data').and_return(false)
    end

    it { is_expected.to run_execute('./add-host www.example.test 192.0.2.10') }
  end

  context 'with an existing record' do
    recipe do
      djbdns_rr 'www.example.test' do
        cwd '/etc/djbdns/tinydns-internal/root'
        ip '192.0.2.10'
        type 'host'
      end
    end

    before do
      allow(::File).to receive(:exist?).and_call_original
      allow(::File).to receive(:exist?).with('/etc/djbdns/tinydns-internal/root/data').and_return(true)
      allow(::File).to receive(:readlines).with('/etc/djbdns/tinydns-internal/root/data').and_return(["=www.example.test:192.0.2.10:86400\n"])
    end

    it { is_expected.to_not run_execute('./add-host www.example.test 192.0.2.10') }
  end

  context 'delete action' do
    recipe do
      djbdns_rr 'www.example.test' do
        cwd '/etc/djbdns/tinydns-internal/root'
        ip '192.0.2.10'
        action :delete
      end
    end

    before do
      allow(::File).to receive(:exist?).and_call_original
      allow(::File).to receive(:exist?).with('/etc/djbdns/tinydns-internal/root/data').and_return(true)
    end

    it { is_expected.to run_ruby_block('remove www.example.test from tinydns data') }
  end
end
