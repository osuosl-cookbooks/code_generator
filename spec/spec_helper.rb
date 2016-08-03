require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-dk/generator'

ChefSpec::Coverage.start! { add_filter 'code_generator' }

CENTOS_7_OPTS = {
  platform: 'centos',
  version: '7.2.1511',
  log_level: :fatal
}.freeze

CENTOS_6_OPTS = {
  platform: 'centos',
  version: '6.7',
  log_level: :fatal
}.freeze

DEBIAN_8_OPTS = {
  platform: 'debian',
  version: '8.4',
  log_level: :fatal
}.freeze

ALL_PLATFORMS = [
  CENTOS_7_OPTS,
  CENTOS_6_OPTS,
  DEBIAN_8_OPTS
].freeze

RHEL_PLATFORM = [
  CENTOS_7_OPTS,
  CENTOS_6_OPTS
].freeze

DEBIAN_PLATFORM = [
  DEBIAN_8_OPTS
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
  end
end
