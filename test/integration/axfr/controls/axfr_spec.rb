control 'axfrdns' do
  describe service('axfrdns') do
    it { should be_running }
  end

  describe file('/etc/service/axfrdns') do
    it { should be_symlink }
  end
end
