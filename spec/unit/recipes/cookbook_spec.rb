require_relative '../../spec_helper'

describe 'code_generator::cookbook' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(CENTOS_7_OPTS).converge(described_recipe)
  end
  include_context 'common_stubs'
  base_dir = '/tmp/test-cookbook'
  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end
  [
    'Ensuring correct cookbook file content',
    'Committing cookbook files to git',
  ].each do |g|
    it do
      expect(chef_run).to write_generator_desc(g)
    end
  end
  it "creates #{base_dir} directory" do
    expect(chef_run).to create_directory(base_dir)
  end
  %w(
    attributes
    recipes
    spec/unit/recipes
    test/integration/default/inspec
  ).each do |d|
    it "creates #{base_dir}/#{d} directory" do
      expect(chef_run).to create_directory(File.join(base_dir, d))
    end
  end
  %w(
    Berksfile
    Rakefile
    .rspec
    .rubocop.yml
  ).each do |d|
    it "creates #{base_dir}/#{d} file if missing" do
      expect(chef_run).to create_cookbook_file_if_missing(
        File.join(base_dir, d))
    end
  end
  it do
    expect(chef_run).to create_template_if_missing("#{base_dir}/test/integration/default/inspec/default_spec.rb")
  end
  %w(
    chefignore
    .gitignore
  ).each do |d|
    it "creates #{base_dir}/#{d} file" do
      expect(chef_run).to create_cookbook_file(File.join(base_dir, d))
    end
  end
  it "creates #{base_dir}/attributes/default.rb file" do
    expect(chef_run).to create_template_if_missing(File.join(base_dir, 'attributes', 'default.rb'))
  end
  describe File.join(base_dir, 'metadata.rb') do
    let(:file) { chef_run.template(File.join(base_dir, 'metadata.rb')) }
    [
      /^name             'test-cookbook'$/,
      /^maintainer       'Oregon State University'$/,
      /^maintainer_email 'chef@osuosl.org'$/,
      /^license          'Apache-2.0'$/,
      %r{^issues_url\s*'https://github.com/osuosl-cookbooks/test-cookbook/\
issues'$},
      %r{^source_url\s*'https://github.com/osuosl-cookbooks/test-cookbook'$},
      /^supports         'centos', '~> 7.0'$/,
    ].each do |line|
      it do
        expect(chef_run).to render_file(file.name)
          .with_content(line)
      end
    end
  end
  describe File.join(base_dir, 'README.md') do
    let(:file) { chef_run.template(File.join(base_dir, 'README.md')) }
    [
      /^test-cookbook Cookbook$/,
      /^#### test-cookbook::default$/,
      /"recipe\[test-cookbook\]"/,
      /^- Author:: Oregon State University <chef@osuosl.org>$/,
      /^Copyright:: \d{4}, Oregon State University$/,
      /^Licensed under the Apache License/,
    ].each do |line|
      it do
        expect(chef_run).to render_file(file.name)
          .with_content(line)
      end
    end
  end
  describe File.join(base_dir, 'CHANGELOG.md') do
    let(:file) { chef_run.template(File.join(base_dir, 'CHANGELOG.md')) }
    [
      /^test-cookbook CHANGELOG$/,
      /^- Initial release of test-cookbook$/,
    ].each do |line|
      it do
        expect(chef_run).to render_file(file.name)
          .with_content(line)
      end
    end
  end
  describe File.join(base_dir, 'LICENSE') do
    let(:file) { chef_run.template(File.join(base_dir, 'LICENSE')) }
    [
      /Apache License/,
      /Version 2.0, January 2004/,
    ].each do |line|
      it do
        expect(chef_run).to render_file(file.name).with_content(line)
      end
    end
  end
  describe File.join(base_dir, 'spec', 'spec_helper.rb') do
    let(:file) do
      chef_run.template(File.join(base_dir, 'spec', 'spec_helper.rb'))
    end
    it do
      expect(chef_run).to render_file(file.name)
        .with_content(/^ChefSpec::Coverage.start! { add_filter 'test-cookbook' }$/)
    end
  end
  describe File.join(base_dir, 'spec', 'unit', 'recipes', 'default_spec.rb') do
    let(:file) do
      chef_run.template(File.join(base_dir, 'spec', 'unit', 'recipes', 'default_spec.rb'))
    end
    it do
      expect(chef_run).to render_file(file.name).with_content(/^describe 'test-cookbook::default' do$/)
    end
  end
  describe File.join(base_dir, 'recipes', '.kitchen.yml') do
    let(:file) { chef_run.template(File.join(base_dir, '.kitchen.yml')) }
    it do
      expect(chef_run).to render_file(file.name).with_content(/^verifier:\n  name: inspec$/)
    end
    it do
      expect(chef_run).to render_file(file.name).with_content(/- recipe\[test-cookbook::default\]$/)
    end
  end
  it do
    expect(chef_run).to_not create_template_if_missing('/tmp/test-cookbook/test/smoke/default/default_test.rb')
  end
  describe File.join(base_dir, 'recipes', 'default.rb') do
    let(:file) do
      chef_run.template(File.join(base_dir, 'recipes', 'default.rb'))
    end
    [
      /^# Cookbook:: test-cookbook$/,
      /^# Recipe:: default$/,
      /^# Copyright:: \d{4}, Oregon State University$/,
      /^# Licensed under the Apache License/,
    ].each do |line|
      it do
        expect(chef_run).to render_file(file.name) .with_content(line)
      end
    end
  end
  %w(
    initialize-git
    git-add-new-files
    git-commit-new-files
  ).each do |e|
    it do
      expect(chef_run).to run_execute(e)
    end
  end
end
