context = ChefCLI::Generator.context
osl_defaults!(context)
cookbook_dir = osl_cookbook_dir!(context)
resource_name = context.new_file_basename.tr('-', '_')
fixture = osl_fixture(cookbook_dir, context.cookbook_name, (context.fixture if context.respond_to?(:fixture)))
inspec_dir = File.join(cookbook_dir, 'test', 'integration', resource_name)

# Resource
directory File.join(cookbook_dir, 'resources')

template File.join(cookbook_dir, 'resources', "#{resource_name}.rb") do
  source 'resource.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  variables(resource_name: resource_name)
  action :create_if_missing
end

# Fixture cookbook, created on first use and wired into the Berksfile
directory File.join(fixture[:dir], 'recipes') do
  recursive true
end

unless fixture[:exists]
  template File.join(fixture[:dir], 'metadata.rb') do
    source 'fixture_metadata.rb.erb'
    helpers(ChefCLI::Generator::TemplateHelper)
    variables(fixture_name: fixture[:name])
    action :create_if_missing
  end

  berksfile = File.join(cookbook_dir, 'Berksfile')
  fixture_path = fixture[:dir].delete_prefix("#{cookbook_dir}/")

  ruby_block "add #{fixture[:name]} to the Berksfile" do
    block do
      content = osl_berksfile_with_fixture(File.read(berksfile), fixture[:name], fixture_path)
      File.write(berksfile, content) if content
    end
    only_if { ::File.exist?(berksfile) }
  end
end

template File.join(fixture[:dir], 'recipes', "#{resource_name}.rb") do
  source 'fixture_recipe.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  variables(resource_name: resource_name)
  action :create_if_missing
end

# Chefspec
directory File.join(cookbook_dir, 'spec', 'unit', 'resources') do
  recursive true
end

template File.join(cookbook_dir, 'spec', 'unit', 'resources', "#{resource_name}_spec.rb") do
  source 'resource_spec.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  variables(resource_name: resource_name, fixture_name: fixture[:name])
  action :create_if_missing
end

# InSpec
directory File.join(inspec_dir, 'controls') do
  recursive true
end

template File.join(inspec_dir, 'controls', "#{resource_name}.rb") do
  source 'inspec_default_test.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  variables(profile_name: resource_name)
  action :create_if_missing
end

template File.join(inspec_dir, 'inspec.yml') do
  source 'inspec.yml.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  variables(profile_name: resource_name)
  action :create_if_missing
end
