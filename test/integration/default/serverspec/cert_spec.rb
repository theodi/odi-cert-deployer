require 'serverspec'
set :backend, :exec

describe file '/etc/certs/xero/privatekey.pem' do
  it { should exist }
end
