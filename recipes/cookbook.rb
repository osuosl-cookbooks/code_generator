context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

# cookbook root dir
directory cookbook_dir

# metadata.rb
template "#{cookbook_dir}/metadata.rb" do
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# README
template "#{cookbook_dir}/README.md" do
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# chefignore
cookbook_file "#{cookbook_dir}/chefignore"

# Berks
cookbook_file "#{cookbook_dir}/Berksfile" do
  action :create_if_missing
end

# rubocop
cookbook_file "#{cookbook_dir}/.rubocop.yml" do
  source 'rubocop.yml'
  action :create_if_missing
end

# Tests
test_dir = "#{cookbook_dir}/test/integration/default/serverspec"

directory test_dir do
  recursive true
end

template "#{test_dir}/default_spec.rb" do
  source 'serverspec.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# TK
%w(kitchen.yml kitchen.cloud.yml).each do |k|
  template "#{cookbook_dir}/.#{k}" do
    source "#{k}.erb"
    helpers(ChefDK::Generator::TemplateHelper)
    action :create_if_missing
  end
end

# Recipes
directory "#{cookbook_dir}/recipes"

template "#{cookbook_dir}/recipes/default.rb" do
  source 'default_recipe.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# git
if context.have_git
  unless context.skip_git_init

    execute('initialize-git') do
      command('git init .')
      cwd cookbook_dir
    end
  end

  cookbook_file "#{cookbook_dir}/.gitignore" do
    source 'gitignore'
  end
end
