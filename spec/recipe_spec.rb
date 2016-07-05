require_relative 'spec_helper'

describe 'code_generator::recipe' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(CENTOS_7_OPTS).converge(described_recipe)
  end
  include_context 'common_stubs'
  base_dir = '/tmp/test-cookbook'
  before do
    ChefDK::Generator.add_attr_to_context(:recipe_name, 'foo')
    ChefDK::Generator.add_attr_to_context(:new_file_basename, 'foo')
  end
  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end
  describe File.join(base_dir, 'recipes', 'foo.rb') do
    let(:file) do
      chef_run.template(File.join(
                          base_dir,
                          'recipes',
                          'foo.rb'
      ))
    end
    [
      /^# Cookbook Name:: test-cookbook$/,
      /^# Recipe:: foo$/,
      /^# Copyright \d{4} Oregon State University$/,
      /^# Licensed under the Apache License/
    ].each do |line|
      it do
        expect(chef_run).to render_file(file.name)
          .with_content(line)
      end
    end
  end
  describe File.join(base_dir, 'spec', 'spec_helper.rb') do
    let(:file) do
      chef_run.template(File.join(
                          base_dir,
                          'spec',
                          'spec_helper.rb')
                       )
    end
    it do
      expect(chef_run).to render_file(file.name)
        .with_content(
          /^ChefSpec::Coverage.start! { add_filter 'test-cookbook' }$/
        )
    end
  end
  describe File.join(base_dir, 'spec', 'foo_spec.rb') do
    let(:file) do
      chef_run.template(File.join(
                          base_dir,
                          'spec',
                          'foo_spec.rb')
                       )
    end
    it do
      expect(chef_run).to render_file(file.name)
        .with_content(
          /^describe 'test-cookbook::foo' do$/
        )
    end
  end
  it "creates #{base_dir}/test/integration/foo/serverspec directory" do
    expect(chef_run).to create_directory(File.join(
                                           base_dir,
                                           'test',
                                           'integration',
                                           'foo',
                                           'serverspec'
    ))
  end
  it "creates #{base_dir}/spec directory" do
    expect(chef_run).to create_directory(File.join(base_dir, 'spec'))
  end
  it "creates #{base_dir}/test/integration/foo/serverspec/foo_spec.rb if \
    missing" do
    expect(chef_run).to create_cookbook_file_if_missing(File.join(
                                                          base_dir,
                                                          'test',
                                                          'integration',
                                                          'foo',
                                                          'serverspec',
                                                          'foo_spec.rb'
    ))
  end
end
