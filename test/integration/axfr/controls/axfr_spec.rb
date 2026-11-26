control 'axfrdns' do
  describe command('sv status /etc/service/axfrdns') do
    its('stdout') { should match(/^run:/) }
  end

  describe command('dig @127.0.0.1 example.test AXFR +time=2 +tries=1') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/^example\.test\.\s+\d+\s+IN\s+SOA\s/m) }
    its('stdout') { should match(/^;; XFR size: [1-9]\d* records/) }
  end

  describe file('/etc/service/axfrdns') do
    it { should be_symlink }
  end
end
