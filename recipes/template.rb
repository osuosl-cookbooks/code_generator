context = ChefCLI::Generator.context
cookbook_dir = osl_cookbook_dir!(context)
template_dir = File.join(cookbook_dir, 'templates')
template_filename = context.new_file_basename

unless File.extname(template_filename) == '.erb'
  # new_file_basename is a frozen string, so we have to create an entirely
  # new string here instead of using concat.
  template_filename = "#{template_filename}.erb"
end

template_path = File.join(cookbook_dir, 'templates', template_filename)

directory template_dir do
  recursive true
end

if context.content_source
  osl_warn_kept(template_path, context.content_source) if File.exist?(template_path)

  file template_path do
    content(IO.read(context.content_source))
    action :create_if_missing
  end

else

  template template_path do
    source 'template.erb'
    helpers(ChefCLI::Generator::TemplateHelper)
    action :create_if_missing
  end

end
