require_relative '../../spec_helper'

describe 'code_generator::resource' do
  base_dir = '/tmp/test-cookbook'
  fixture_glob = "#{base_dir}/test/{cookbooks,fixtures/cookbooks}/*/metadata.rb"
  include_context 'common_stubs'
  before do
    ChefCLI::Generator.add_attr_to_context(:recipe_name, 'osl_foo')
    ChefCLI::Generator.add_attr_to_context(:new_file_basename, 'osl_foo')
    ChefCLI::Generator.add_attr_to_context(:fixture, nil)
  end

  context 'without a fixture cookbook' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }
    fixture_dir = "#{base_dir}/test/cookbooks/test_cookbook_test"

    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with("#{base_dir}/Berksfile").and_return(true)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it { expect(chef_run).to create_directory("#{base_dir}/resources") }
    it { expect(chef_run).to create_template_if_missing("#{base_dir}/resources/osl_foo.rb") }

    it do
      expect(chef_run).to render_file("#{base_dir}/resources/osl_foo.rb").with_content(<<~EOF)
        provides :osl_foo
        unified_mode true
        default_action :create

        # property :name_of_thing, String, name_property: true

        action :create do
        end
      EOF
    end

    it { expect(chef_run).to create_directory("#{fixture_dir}/recipes") }
    it { expect(chef_run).to create_template_if_missing("#{fixture_dir}/metadata.rb") }

    it do
      expect(chef_run).to render_file("#{fixture_dir}/metadata.rb").with_content(<<~EOF)
        name             'test_cookbook_test'
        maintainer       'Oregon State University'
        maintainer_email 'chef@osuosl.org'
        license          'Apache-2.0'
        description      'Test wrapper for test-cookbook'
        version          '0.1.0'

        depends 'test-cookbook'
      EOF
    end

    it { expect(chef_run).to run_ruby_block('add test_cookbook_test to the Berksfile') }
    it { expect(chef_run).to render_file("#{fixture_dir}/recipes/osl_foo.rb").with_content("osl_foo 'default'\n") }

    it do
      expect(chef_run).to render_file("#{base_dir}/spec/unit/resources/osl_foo_spec.rb").with_content(
        /^describe 'test_cookbook_test::osl_foo' do$/
      )
    end

    it do
      expect(chef_run).to render_file("#{base_dir}/spec/unit/resources/osl_foo_spec.rb").with_content(
        /step_into: %w\(osl_foo\)/
      )
    end

    it do
      expect(chef_run).to render_file("#{base_dir}/test/integration/osl_foo/controls/osl_foo.rb").with_content(
        "control 'osl_foo' do\n  title 'TODO: prove osl_foo works end to end'\nend\n"
      )
    end

    it { expect(chef_run).to create_template_if_missing("#{base_dir}/test/integration/osl_foo/inspec.yml") }
  end

  context 'with an existing fixture cookbook' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }
    fixture_dir = "#{base_dir}/test/cookbooks/foo-test"

    before do
      allow(Dir).to receive(:glob).and_call_original
      allow(Dir).to receive(:glob).with(fixture_glob).and_return(["#{fixture_dir}/metadata.rb"])
    end

    it { expect(chef_run).to_not create_template_if_missing("#{fixture_dir}/metadata.rb") }
    it { expect(chef_run).to_not run_ruby_block('add foo-test to the Berksfile') }
    it { expect(chef_run).to create_template_if_missing("#{fixture_dir}/recipes/osl_foo.rb") }

    it do
      expect(chef_run).to render_file("#{base_dir}/spec/unit/resources/osl_foo_spec.rb").with_content(
        /^describe 'foo-test::osl_foo' do$/
      )
    end
  end

  context 'with -a fixture naming one of several fixture cookbooks' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }
    fixture_dir = "#{base_dir}/test/cookbooks/web2-test"

    before do
      ChefCLI::Generator.add_attr_to_context(:fixture, 'web2-test')
      allow(Dir).to receive(:glob).and_call_original
      allow(Dir).to receive(:glob).with(fixture_glob).and_return(
        ["#{base_dir}/test/cookbooks/web1-test/metadata.rb", "#{fixture_dir}/metadata.rb"]
      )
    end

    it { expect(chef_run).to_not create_template_if_missing("#{fixture_dir}/metadata.rb") }
    it { expect(chef_run).to_not run_ruby_block('add web2-test to the Berksfile') }
    it { expect(chef_run).to create_template_if_missing("#{fixture_dir}/recipes/osl_foo.rb") }
  end

  context 'with -a fixture naming a new fixture cookbook' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }
    fixture_dir = "#{base_dir}/test/cookbooks/bar_test"

    before do
      ChefCLI::Generator.add_attr_to_context(:fixture, 'bar_test')
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with("#{base_dir}/Berksfile").and_return(true)
    end

    it { expect(chef_run).to create_template_if_missing("#{fixture_dir}/metadata.rb") }
    it { expect(chef_run).to run_ruby_block('add bar_test to the Berksfile') }
    it { expect(chef_run).to create_template_if_missing("#{fixture_dir}/recipes/osl_foo.rb") }
  end

  context 'with a dashed resource name' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }

    before do
      ChefCLI::Generator.add_attr_to_context(:new_file_basename, 'osl-foo-bar')
    end

    it do
      expect(chef_run).to render_file("#{base_dir}/resources/osl_foo_bar.rb").with_content(
        /^provides :osl_foo_bar$/
      )
    end

    it { expect(chef_run).to create_template_if_missing("#{base_dir}/spec/unit/resources/osl_foo_bar_spec.rb") }

    it do
      expect(chef_run).to render_file("#{base_dir}/test/integration/osl_foo_bar/inspec.yml").with_content(
        /^name: osl_foo_bar$/
      )
    end

    it do
      expect(chef_run).to render_file("#{base_dir}/test/integration/osl_foo_bar/controls/osl_foo_bar.rb").with_content(
        /^control 'osl_foo_bar' do$/
      )
    end
  end
end

describe 'code_generator::resource', 'with . as the cookbook path' do
  cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge('code_generator::resource') }
  include_context 'common_stubs'
  base_dir = '/tmp/osl-dot/.'
  fixture_dir = "#{base_dir}/test/cookbooks/dot_test"
  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("#{base_dir}/metadata.rb").and_return(true)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with("#{base_dir}/metadata.rb").and_return("name 'osl-dot'\n")
    allow(File).to receive(:exist?).with("#{base_dir}/Berksfile").and_return(true)
  end
  before(:all) do
    ChefCLI::Generator.add_attr_to_context(:cookbook_root, '/tmp/osl-dot')
    ChefCLI::Generator.add_attr_to_context(:cookbook_name, '.')
    ChefCLI::Generator.add_attr_to_context(:recipe_name, 'osl_dot_thing')
    ChefCLI::Generator.add_attr_to_context(:new_file_basename, 'osl_dot_thing')
    ChefCLI::Generator.add_attr_to_context(:fixture, nil)
  end

  it { expect(chef_run).to render_file("#{fixture_dir}/metadata.rb").with_content(/^depends 'osl-dot'$/) }
  it { expect(chef_run).to run_ruby_block('add dot_test to the Berksfile') }

  it do
    expect(chef_run).to render_file("#{base_dir}/spec/unit/resources/osl_dot_thing_spec.rb").with_content(
      /^describe 'dot_test::osl_dot_thing' do$/
    )
  end
end
