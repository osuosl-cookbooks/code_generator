context = ChefCLI::Generator.context
osl_defaults!(context)
cookbook_dir = osl_cookbook_dir!(context)
recipe_path = File.join(cookbook_dir, 'recipes', "#{context.new_file_basename}.rb")
spec_helper_path = File.join(cookbook_dir, 'spec', 'spec_helper.rb')
spec_dir = File.join(cookbook_dir, 'spec', 'unit', 'recipes')
spec_path = File.join(spec_dir, "#{context.new_file_basename}_spec.rb")
inspec_dir = File.join(cookbook_dir, 'test', 'integration', context.new_file_basename)
inspec_control = File.join(inspec_dir, 'controls', "#{context.new_file_basename}.rb")
inspec_yaml = File.join(inspec_dir, 'inspec.yml')

# Chefspec
directory spec_dir do
  recursive true
end

cookbook_file spec_helper_path do
  action :create_if_missing
end

template spec_path do
  source 'recipe_spec.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end

# InSpec
directory "#{inspec_dir}/controls" do
  recursive true
end

template inspec_control do
  source 'inspec_default_test.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end

template inspec_yaml do
  source 'inspec.yml.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end

# Recipe
template recipe_path do
  source 'recipe.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end
