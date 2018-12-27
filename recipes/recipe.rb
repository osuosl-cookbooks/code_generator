
context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)
recipe_path = File.join(cookbook_dir, 'recipes', "#{context.new_file_basename}.rb")
spec_helper_path = File.join(cookbook_dir, 'spec', 'spec_helper.rb')
spec_dir = File.join(cookbook_dir, 'spec', 'unit', 'recipes')
spec_path = File.join(spec_dir, "#{context.new_file_basename}_spec.rb")
inspec_dir = File.join(cookbook_dir, 'test', 'integration', context.new_file_basename, 'inspec')
inspec_path = File.join(inspec_dir, "#{context.new_file_basename}_spec.rb")
# serverspec_dir = File.join(cookbook_dir, 'test', 'integration', context.new_file_basename, 'serverspec')
# serverspec_path = File.join(serverspec_dir, "#{context.new_file_basename}_spec.rb")

context.license = 'apachev2'
context.copyright_holder = 'Oregon State University'

if File.directory?(File.join(cookbook_dir, 'test', 'recipes'))
  Chef::Log.deprecation <<-EOH
It appears that you have Inspec tests located at "test/recipes". This location can
cause issues with Foodcritic and has been deprecated in favor of "test/smoke/default".
Please move your existing Inspec tests to the newly created "test/smoke/default"
directory, and update the 'inspec_tests' value in your .kitchen.yml file(s) to
point to "test/smoke/default".
  EOH
end

# Chefspec
directory spec_dir do
  recursive true
end

template spec_helper_path do
  source 'spec_helper.rb.erb'

  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

template spec_path do
  source 'default_chefspec.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# directory serverspec_dir do
#   recursive true
# end
#
# cookbook_file serverspec_path do
#   source 'serverspec.rb'
#   action :create_if_missing
# end

# Inspec
directory inspec_dir do
  recursive true
end

template inspec_path do
  source 'inspec_default_test.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# Recipe
template recipe_path do
  source 'recipe.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
end
