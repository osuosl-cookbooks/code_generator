require_relative '../../spec_helper'

describe 'code_generator::cookbook' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(CENTOS_8).converge(described_recipe)
  end
  include_context 'common_stubs'
  base_dir = '/tmp/test-cookbook'
  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end
  [
    'Ensuring correct cookbook content',
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
    .rubocop.yml
    spec/spec_helper.rb
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
  describe "#{base_dir}/spec/unit/recipes/default_spec.rb" do
    let(:file) { chef_run.template("#{base_dir}/spec/unit/recipes/default_spec.rb") }
    file_content = <<-EOF
#
# Cookbook:: test-cookbook
# Spec:: default
#
# Copyright:: #{Time.new.year}, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../../spec_helper'

describe 'test-cookbook::default' do
  ALL_PLATFORMS.each do |p|
    context "\#{p[:platform]} \#{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
    end
  end
end
EOF
    it { expect(chef_run).to render_file(file.name).with_content(file_content) }
  end
  describe File.join(base_dir, 'metadata.rb') do
    let(:file) { chef_run.template(File.join(base_dir, 'metadata.rb')) }
    file_content = <<-EOF
name              'test-cookbook'
maintainer        'Oregon State University'
maintainer_email  'chef@osuosl.org'
license           'Apache-2.0'
description       'Installs/Configures test-cookbook'
issues_url        'https://github.com/osuosl-cookbooks/test-cookbook/issues'
source_url        'https://github.com/osuosl-cookbooks/test-cookbook'
chef_version      '>= 16.0'
version           '0.1.0'

supports          'centos', '~> 7.0'
supports          'centos_stream', '~> 8.0'
EOF
    it { expect(chef_run).to render_file(file.name).with_content(file_content) }
  end
  describe File.join(base_dir, 'README.md') do
    let(:file) { chef_run.template(File.join(base_dir, 'README.md')) }
    file_content = <<-EOF
# test-cookbook

TODO: Enter the cookbook description here.

## Requirements

### Platforms

- CentOS 7+

### Cookbooks

## Attributes

## Resources

## Recipes

## Contributing

1. Fork the repository on Github
1. Create a named feature branch (like `username/add_component_x`)
1. Write tests for your change
1. Write your change
1. Run the tests, ensuring they all pass
1. Submit a Pull Request using Github

## License and Authors

- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: #{Time.new.year}, Oregon State University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
EOF
    it { expect(chef_run).to render_file(file.name).with_content(file_content) }
  end
  describe File.join(base_dir, 'CHANGELOG.md') do
    let(:file) { chef_run.template(File.join(base_dir, 'CHANGELOG.md')) }
    file_content = <<-EOF
# test-cookbook CHANGELOG

This file is used to list changes made in each version of the test-cookbook cookbook.

## 0.1.0

- Initial release
EOF
    it { expect(chef_run).to render_file(file.name).with_content(file_content) }
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
  describe File.join(base_dir, 'spec', 'unit', 'recipes', 'default_spec.rb') do
    let(:file) do
      chef_run.template(File.join(base_dir, 'spec', 'unit', 'recipes', 'default_spec.rb'))
    end
    it do
      expect(chef_run).to render_file(file.name).with_content(/^describe 'test-cookbook::default' do$/)
    end
  end
  describe File.join(base_dir, 'recipes', 'kitchen.yml') do
    let(:file) { chef_run.template(File.join(base_dir, 'kitchen.yml')) }
    file_content = <<-EOF
---
verifier:
  name: inspec

provisioner:
  name: chef_infra
  enforce_idempotency: true
  multiple_converge: 2
  deprecations_as_errors: true

suites:
  - name: default
    run_list:
      - recipe[test-cookbook::default]
EOF
    it { expect(chef_run).to render_file(file.name).with_content(file_content) }
  end
  describe File.join(base_dir, 'recipes', 'default.rb') do
    let(:file) do
      chef_run.template(File.join(base_dir, 'recipes', 'default.rb'))
    end
    [
      /^# Cookbook:: test-cookbook$/,
      /^# Recipe:: default$/,
      /^# Copyright:: #{Time.new.year}, Oregon State University$/,
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
