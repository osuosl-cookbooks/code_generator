context = ChefCLI::Generator.context
cookbook_dir = osl_cookbook_dir!(context)
attribute_dir = File.join(cookbook_dir, 'attributes')
attribute_path = File.join(cookbook_dir, 'attributes', "#{context.new_file_basename}.rb")

directory attribute_dir

template attribute_path do
  source 'attribute.rb.erb'
  helpers(ChefCLI::Generator::TemplateHelper)
  action :create_if_missing
end
