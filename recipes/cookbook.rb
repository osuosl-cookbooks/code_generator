context = ChefCLI::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

silence_chef_formatter unless context.verbose

generator_desc('Ensuring correct cookbook content')

# cookbook root dir
directory cookbook_dir

# metadata.rb
spdx_license =  case context.license
                when 'apachev2'
                  'Apache-2.0'
                when 'mit'
                  'MIT'
                when 'gplv2'
                  'GPL-2.0'
                when 'gplv3'
                  'GPL-3.0'
                else
                  'All Rights Reserved'
                end

###
# OSL site config
###
context.use_policyfile = false
context.license = 'apachev2'
context.copyright_holder = 'Oregon State University'
context.email = 'chef@osuosl.org'

template "#{cookbook_dir}/metadata.rb" do
  helpers(ChefCLI::Generator::TemplateHelper)
  variables(
    spdx_license: spdx_license
  )
  action :create_if_missing
end

# README
template "#{cookbook_dir}/README.md" do
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end

# CHANGELOG
template "#{cookbook_dir}/CHANGELOG.md" do
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end

# Rakefile
cookbook_file "#{cookbook_dir}/Rakefile" do
  action :create_if_missing
end

# chefignore
cookbook_file "#{cookbook_dir}/chefignore"

if context.use_policyfile
  # Policyfile
  template "#{cookbook_dir}/Policyfile.rb" do
    source 'Policyfile.rb.erb'
    helpers(ChefCLI::Generator::TemplateHelper)
  end
else
  # Berks
  cookbook_file "#{cookbook_dir}/Berksfile" do
    action :create_if_missing
  end
end

# rubocop
cookbook_file "#{cookbook_dir}/.rubocop.yml" do
  source 'rubocop.yml'
  action :create_if_missing
end

# LICENSE
template "#{cookbook_dir}/LICENSE" do
  helpers(ChefCLI::Generator::TemplateHelper)
  source "LICENSE.#{context.license}.erb"
  action :create_if_missing
end

# Test Kitchen
template "#{cookbook_dir}/kitchen.yml" do
  if context.kitchen == 'dokken'
    # kitchen-dokken configuration works with berkshelf and policyfiles
    source 'kitchen_dokken.yml.erb'
  elsif context.use_policyfile
    source 'kitchen_policyfile.yml.erb'
  else
    source 'kitchen.yml.erb'
  end

  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end

cookbook_file "#{cookbook_dir}/kitchen.openstack.yml" do
  action :create_if_missing
end

cookbook_file "#{cookbook_dir}/kitchen.dokken.yml" do
  action :create_if_missing
end

# InSpec
directory "#{cookbook_dir}/test/integration/default/controls" do
  recursive true
end

template "#{cookbook_dir}/test/integration/default/controls/default.rb" do
  source 'inspec_default_test.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end

template "#{cookbook_dir}/test/integration/default/inspec.yml" do
  source 'inspec.yml.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end

# Chefspec
directory "#{cookbook_dir}/spec/unit/recipes" do
  recursive true
end

cookbook_file "#{cookbook_dir}/spec/spec_helper.rb" do
  if context.use_policyfile
    source 'spec_helper_policyfile.rb'
  else
    source 'spec_helper.rb'
  end

  action :create_if_missing
end

template "#{cookbook_dir}/spec/unit/recipes/default_spec.rb" do
  source 'recipe_spec.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end

# Recipes

directory "#{cookbook_dir}/recipes"

template "#{cookbook_dir}/recipes/default.rb" do
  source 'recipe.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end

# git
if context.have_git
  unless context.skip_git_init

    generator_desc('Committing cookbook files to git')

    execute('initialize-git') do
      command('git init .')
      cwd cookbook_dir
    end

  end

  cookbook_file "#{cookbook_dir}/.gitignore" do
    source 'gitignore'
  end

  unless context.skip_git_init

    execute('git-add-new-files') do
      command('git add .')
      cwd cookbook_dir
    end

    execute('git-commit-new-files') do
      command('git commit -m "Add generated cookbook content"')
      cwd cookbook_dir
    end
  end
end
