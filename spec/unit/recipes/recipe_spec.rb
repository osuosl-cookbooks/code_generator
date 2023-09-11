require_relative '../../spec_helper'

describe 'code_generator::recipe' do
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
  describe File.join(base_dir, 'recipes', 'foo.rb') do
    let(:file) do
      chef_run.template(File.join(base_dir, 'recipes', 'foo.rb'))
    end
    [
      /^# Cookbook:: test-cookbook$/,
      /^# Recipe:: foo$/,
      /^# Copyright:: #{Time.new.year}, Oregon State University$/,
      /^# Licensed under the Apache License/,
    ].each do |line|
      it do
        expect(chef_run).to render_file(file.name)
          .with_content(line)
      end
    end
  end
  describe File.join(base_dir, 'spec', 'unit', 'recipes', 'foo_spec.rb') do
    let(:file) do
      chef_run.template(File.join(base_dir, 'spec', 'unit', 'recipes', 'foo_spec.rb'))
    end
    it do
      expect(chef_run).to render_file(file.name)
        .with_content(/^describe 'test-cookbook::foo' do$/)
    end
  end
  it do
    expect(chef_run).to create_directory(File.join(base_dir, 'test', 'integration', 'foo', 'controls'))
  end
  it do
    expect(chef_run).to create_directory(File.join(base_dir, 'spec', 'unit', 'recipes'))
  end
  it do
    expect(chef_run).to create_template_if_missing(
      File.join(base_dir, 'test', 'integration', 'foo', 'controls', 'foo.rb'))
  end
  it do
    expect(chef_run).to_not create_template_if_missing('/tmp/test-cookbook/test/smoke/default/foo.rb')
  end
end
