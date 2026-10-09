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
  end
end
Chef::DSL::Recipe.include ::CodeGenerator::Helpers
