require 'serverspec'

set :backend, :exec

describe file('/') do
  it { should be_directory }
end
