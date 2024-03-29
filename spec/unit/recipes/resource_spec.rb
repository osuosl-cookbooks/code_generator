require_relative '../../spec_helper'

describe 'code_generator::resource' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(ALMA_8).converge(described_recipe)
  end
  include_context 'common_stubs'
  base_dir = '/tmp/test-cookbook'
  before do
    ChefCLI::Generator.add_attr_to_context(:recipe_name, 'foo')
    ChefCLI::Generator.add_attr_to_context(:new_file_basename, 'foo')
  end

  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end

  it "creates #{base_dir}/resources directory" do
    expect(chef_run).to create_directory(File.join(base_dir, 'resources'))
  end

  describe File.join(base_dir, 'resources', 'foo.rb') do
    let(:file) do
      chef_run.template(File.join(base_dir, 'resources', 'foo.rb'))
    end
    [
      /^resource_name :test_cookbook_foo$/,
      /^provides :test_cookbook_foo$/,
      %r{# INFO: example property -- see https://docs.chef.io/custom_resources/},
      /^# property :foo, String, default: 'bar', description: 'Example property.'$/,
      /^default_action :create$/,
      /^action :create do$/,
    ].each do |line|
      it do
        expect(chef_run).to render_file(file.name)
          .with_content(line)
      end
    end
  end
end
