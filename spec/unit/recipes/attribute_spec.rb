require_relative '../../spec_helper'

describe 'code_generator::attribute' do
  base_dir = '/tmp/test-cookbook'
  cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }
  include_context 'common_stubs'

  it { expect(chef_run).to create_directory("#{base_dir}/attributes") }
  it { expect(chef_run).to create_template_if_missing("#{base_dir}/attributes/default.rb").with(source: 'attribute.rb.erb') }
end
