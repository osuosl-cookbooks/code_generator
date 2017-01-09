if defined?('ChefSpec')
  def write_generator_desc(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:generator_desc,
                                            :write,
                                            resource_name)
  end
end
