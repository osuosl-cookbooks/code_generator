module CodeGenerator
  module Helpers
    def osl_defaults!(context)
      context.license = 'apachev2'
      context.copyright_holder = 'Oregon State University'
      context.email = 'chef@osuosl.org'
    end

    # exit! because chef-cli wraps raise and exit in a 70-line compile-error
    # report that buries the message.
    def osl_unsupported!(command)
      warn "`cinc generate #{command}` is not supported by the OSL code_generator " \
           '(OSL cookbooks use Berkshelf); see its README'
      Kernel.exit!(1)
    end

    def osl_camelize(name)
      name.to_s.split(/[^a-zA-Z]/).map(&:capitalize).join
    end

    def osl_short_name(cookbook_name)
      cookbook_name.sub(/\A(osl|proj)-/, '').tr('-', '_')
    end

    def osl_cookbook_name(dir)
      metadata = File.join(dir, 'metadata.rb')
      name = File.read(metadata)[/^name\s+['"]([^'"]+)['"]/, 1] if File.exist?(metadata)
      name || File.basename(dir)
    end

    # The fixture cookbook a new resource's test recipe goes in, as
    # { name:, dir:, exists: }; an override comes from `-a fixture=<name>`.
    def osl_fixture(cookbook_dir, cookbook_name, override = nil)
      dirs = Dir.glob(File.join(cookbook_dir, 'test', '{cookbooks,fixtures/cookbooks}', '*', 'metadata.rb'))
                .map { |m| File.dirname(m) }.sort
      if override
        dir = dirs.find { |d| [File.basename(d), osl_cookbook_name(d)].include?(override) }
        return { name: override, dir: File.join(cookbook_dir, 'test', 'cookbooks', override), exists: false } unless dir
      elsif dirs.empty?
        name = "#{osl_short_name(cookbook_name)}_test"
        return { name: name, dir: File.join(cookbook_dir, 'test', 'cookbooks', name), exists: false }
      elsif dirs.one?
        dir = dirs.first
      else
        short = osl_short_name(cookbook_name)
        preferred = ["#{short}_test", "#{short}-test", "#{cookbook_name}-test"]
        dir = dirs.find { |d| preferred.include?(File.basename(d)) }
        unless dir
          raise "Several fixture cookbooks (#{dirs.map { |d| File.basename(d) }.join(', ')}); " \
                'pick one with -a fixture=<name>'
        end
      end
      { name: osl_cookbook_name(dir), dir: dir, exists: true }
    end

    # Berksfile content with a path line for the fixture, or nil if it is
    # already there; it goes after the last path line, else above metadata.
    def osl_berksfile_with_fixture(content, name, path)
      return if content.match?(/^cookbook\s+['"]#{Regexp.escape(name)}['"]/)
      line = "cookbook '#{name}', path: '#{path}'\n"
      lines = content.lines
      last = lines.rindex { |l| l.match?(/^cookbook\s.*path:/) }
      if last
        lines.insert(last + 1, line)
      elsif (meta = lines.index { |l| l.match?(/^metadata\b/) })
        lines.insert(meta, line, "\n")
      else
        lines << "\n" unless content.empty? || content.end_with?("\n\n")
        lines << line
      end
      lines.join
    end
  end
end
Chef::DSL::Recipe.include ::CodeGenerator::Helpers
Chef::Resource.include ::CodeGenerator::Helpers
