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

  context 'when deleting a specific host record' do
    let(:existing_records) do
      [
        "=www.example.test:192.0.2.1:3600\n",
        "=www.example.test:192.0.2.10:3600\n",
        "+www.example.test:192.0.2.1:3600\n",
      ]
    end

    recipe do
      djbdns_rr 'www.example.test' do
        ip '192.0.2.1'
        cwd '/etc/djbdns/tinydns/root'
        action :remove
      end
    end

    before do
      path = '/etc/djbdns/tinydns/root/data'
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(path).and_return(true)
      allow(File).to receive(:readlines).and_call_original
      allow(File).to receive(:readlines).with(path).and_return(existing_records)
    end

    it 'keeps records with a different address or record type' do
      is_expected.to render_file('/etc/djbdns/tinydns/root/data').with_content(/\A#{Regexp.escape(existing_records.drop(1).join)}\z/)
    end
  end
end
