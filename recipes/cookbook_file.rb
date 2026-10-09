context = ChefCLI::Generator.context
cookbook_dir = osl_cookbook_dir!(context)
files_dir = File.join(cookbook_dir, 'files')
cookbook_file_path = File.join(files_dir, context.new_file_basename)

directory files_dir do
  recursive true
end

if context.content_source
  osl_warn_kept(cookbook_file_path, context.content_source) if File.exist?(cookbook_file_path)

  file cookbook_file_path do
    content(IO.read(context.content_source))
    action :create_if_missing
  end

else

  template cookbook_file_path do
    source 'cookbook_file.erb'
    helpers(ChefCLI::Generator::TemplateHelper)
    action :create_if_missing
  end

end
