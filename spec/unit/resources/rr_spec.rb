# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_rr' do
  step_into :djbdns_rr
  platform 'ubuntu', '24.04'

  recipe do
    djbdns_rr 'www.example.test' do
      cwd '/etc/djbdns/tinydns/root'
      ip '192.0.2.10'
      type 'host'
    end
  end

  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/etc/djbdns/tinydns/root/data').and_return(true)
    allow(File).to receive(:readlines).and_call_original
    allow(File).to receive(:readlines).with('/etc/djbdns/tinydns/root/data').and_return([])
  end

  it { is_expected.to run_execute('./add-host www.example.test 192.0.2.10').with(cwd: '/etc/djbdns/tinydns/root') }
end
