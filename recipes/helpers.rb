context = ChefCLI::Generator.context
cookbook_dir = osl_cookbook_dir!(context)
library_name = context.new_file_basename
libraries_dir = File.join(cookbook_dir, 'libraries')
spec_dir = File.join(cookbook_dir, 'spec', 'unit', 'libraries')
helper_variables = {
  cookbook_class_name: osl_camelize(context.cookbook_name),
  helper_class_name: 'Helpers',
  library_name: library_name,
}

directory libraries_dir

template File.join(libraries_dir, "#{library_name}.rb") do
  source 'helpers.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  variables(helper_variables)
  action :create_if_missing
end

# Chefspec
directory spec_dir do
  recursive true
end

template File.join(spec_dir, "#{library_name}_spec.rb") do
  source 'library_spec.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  variables(helper_variables)
  action :create_if_missing
end
