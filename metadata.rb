name             'code_generator'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
source_url       'https://github.com/osuosl-cookbooks/code_generator'
issues_url       'https://github.com/osuosl-cookbooks/code_generator/issues'
license          'Apache-2.0'
chef_version     '>= 12.18' if respond_to?(:chef_version)
description      'Generates Chef code for the OSUOSL'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.8'
supports         'centos', '~> 7.0'
