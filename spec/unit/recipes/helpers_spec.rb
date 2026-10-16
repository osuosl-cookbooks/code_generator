require_relative '../../spec_helper'

describe 'code_generator::helpers' do
  base_dir = '/tmp/test-cookbook'
  cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }
  include_context 'common_stubs'
  before do
    ChefCLI::Generator.add_attr_to_context(:new_file_basename, 'helpers')
  end

  it { expect(chef_run).to create_directory("#{base_dir}/libraries") }
  it { expect(chef_run).to create_template_if_missing("#{base_dir}/libraries/helpers.rb") }

  it do
    expect(chef_run).to render_file("#{base_dir}/libraries/helpers.rb").with_content(<<~EOF)
      module TestCookbook
        module Cookbook
          module Helpers
            # Prefix helper names with the cookbook name, e.g. test_cookbook_installed?
          end
        end
      end
      Chef::DSL::Recipe.include ::TestCookbook::Cookbook::Helpers
      Chef::Resource.include ::TestCookbook::Cookbook::Helpers
    EOF
  end

  it { expect(chef_run).to create_directory("#{base_dir}/spec/unit/libraries") }

  it do
    expect(chef_run).to render_file("#{base_dir}/spec/unit/libraries/helpers_spec.rb").with_content(<<~EOF)
      require_relative '../../spec_helper'
      require_relative '../../../libraries/helpers'

      describe TestCookbook::Cookbook::Helpers do
        subject { Object.new.extend(described_class) }
      end
    EOF
  end
end

describe 'code_generator::helpers', 'with . as the cookbook path' do
  cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge('code_generator::helpers') }
  include_context 'common_stubs'
  base_dir = '/tmp/osl-dot/.'
  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("#{base_dir}/metadata.rb").and_return(true)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with("#{base_dir}/metadata.rb").and_return("name 'osl-dot'\n")
  end
  before(:all) do
    ChefCLI::Generator.add_attr_to_context(:cookbook_root, '/tmp/osl-dot')
    ChefCLI::Generator.add_attr_to_context(:cookbook_name, '.')
    ChefCLI::Generator.add_attr_to_context(:new_file_basename, 'helpers')
  end

  it { expect(chef_run).to render_file("#{base_dir}/libraries/helpers.rb").with_content(/^module OslDot$/) }
end
