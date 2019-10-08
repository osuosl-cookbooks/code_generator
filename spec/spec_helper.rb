require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-dk/generator'
require 'chef-dk/command/generator_commands/chef_exts/recipe_dsl_ext'
require 'chef-dk/command/generator_commands/chef_exts/quieter_doc_formatter'
require 'chef-dk/command/generator_commands/chef_exts/generator_desc_resource'
require_relative 'support/matchers'

CENTOS_7_OPTS = {
  platform: 'centos',
  version: '7',
  log_level: :warn,
}.freeze

CENTOS_6_OPTS = {
  platform: 'centos',
  version: '6',
  log_level: :warn,
}.freeze

DEBIAN_9_OPTS = {
  platform: 'debian',
  version: '8',
  log_level: :warn,
}.freeze

ALL_PLATFORMS = [
  CENTOS_7_OPTS,
  CENTOS_6_OPTS,
  DEBIAN_9_OPTS,
].freeze

RHEL_PLATFORM = [
  CENTOS_7_OPTS,
  CENTOS_6_OPTS,
].freeze

DEBIAN_PLATFORM = [
  DEBIAN_9_OPTS,
].freeze

shared_context 'common_stubs' do
  before do
    stub_command('git init .').and_return(true)
    ChefDK::Generator.reset
    ChefDK::Generator.add_attr_to_context(:cookbook_name, 'test-cookbook')
    ChefDK::Generator.add_attr_to_context(:cookbook_root, '/tmp')
    ChefDK::Generator
      .add_attr_to_context(:copyright_holder, 'Oregon State University')
    ChefDK::Generator.add_attr_to_context(:email, 'chef@osuosl.org')
    ChefDK::Generator.add_attr_to_context(:have_git, true)
    ChefDK::Generator.add_attr_to_context(:license, 'apachev2')
    ChefDK::Generator.add_attr_to_context(:new_file_basename, 'default')
    ChefDK::Generator.add_attr_to_context(:recipe_name, 'default')
    ChefDK::Generator.add_attr_to_context(:content_source, nil)
    ChefDK::Generator.add_attr_to_context(:skip_git_init, false)
    ChefDK::Generator.add_attr_to_context(:verbose, false)
    ChefDK::Generator.add_attr_to_context(:enable_delivery, false)
    ChefDK::Generator.add_attr_to_context(:use_berkshelf, true)
  end
end
