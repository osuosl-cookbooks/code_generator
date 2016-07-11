
context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)
recipe_name = context.new_file_basename
recipe_path = File.join(cookbook_dir, 'recipes',
                        "#{recipe_name}.rb")
serverspec_dir = "#{cookbook_dir}/test/integration/#{recipe_name}/serverspec"

context.license = 'apachev2'
context.copyright_holder = 'Oregon State University'

template recipe_path do
  source 'recipe.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

directory File.join(cookbook_dir, 'spec') do
  recursive true
end

template "#{cookbook_dir}/spec/spec_helper.rb" do
  source 'spec_helper.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

template "#{cookbook_dir}/spec/#{recipe_name}_spec.rb" do
  source 'default_chefspec.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

directory serverspec_dir do
  recursive true
end

cookbook_file "#{serverspec_dir}/#{recipe_name}_spec.rb" do
  source 'serverspec.rb'
  action :create_if_missing
end
