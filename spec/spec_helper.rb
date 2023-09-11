require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-cli/generator'
require 'chef-cli/command/generator_commands/chef_exts/recipe_dsl_ext'
require 'chef-cli/command/generator_commands/chef_exts/quieter_doc_formatter'
require 'chef-cli/command/generator_commands/chef_exts/generator_desc_resource'
require_relative 'support/matchers'

ALMA_8 = {
  platform: 'almalinux',
  version: '8',
  log_level: :warn,
}.freeze

shared_context 'common_stubs' do
  before do
    stub_command('git init .').and_return(true)
    ChefCLI::Generator.reset
    ChefCLI::Generator.add_attr_to_context(:cookbook_name, 'test-cookbook')
    ChefCLI::Generator.add_attr_to_context(:cookbook_root, '/tmp')
    ChefCLI::Generator.add_attr_to_context(:copyright_holder, 'Oregon State University')
    ChefCLI::Generator.add_attr_to_context(:email, 'chef@osuosl.org')
    ChefCLI::Generator.add_attr_to_context(:have_git, true)
    ChefCLI::Generator.add_attr_to_context(:license, 'apachev2')
    ChefCLI::Generator.add_attr_to_context(:new_file_basename, 'default')
    ChefCLI::Generator.add_attr_to_context(:recipe_name, 'default')
    ChefCLI::Generator.add_attr_to_context(:content_source, nil)
    ChefCLI::Generator.add_attr_to_context(:skip_git_init, false)
    ChefCLI::Generator.add_attr_to_context(:verbose, false)
    ChefCLI::Generator.add_attr_to_context(:use_policyfile, false)
    ChefCLI::Generator.add_attr_to_context(:use_berkshelf, true)
    ChefCLI::Generator.add_attr_to_context(:kitchen, 'vagrant')
  end
end
