require_relative '../../spec_helper'

describe 'code_generator::template' do
  base_dir = '/tmp/test-cookbook'
  include_context 'common_stubs'
  before do
    ChefCLI::Generator.add_attr_to_context(:new_file_basename, 'foo.conf')
    ChefCLI::Generator.add_attr_to_context(:content_source, nil)
  end

  context 'without a source file' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }

    it { expect(chef_run).to create_directory("#{base_dir}/templates") }
    it { expect(chef_run).to create_template_if_missing("#{base_dir}/templates/foo.conf.erb").with(source: 'template.erb') }
  end

  context 'with a name already ending in .erb' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }

    before do
      ChefCLI::Generator.add_attr_to_context(:new_file_basename, 'foo.conf.erb')
    end

    it { expect(chef_run).to create_template_if_missing("#{base_dir}/templates/foo.conf.erb") }
    it { expect(chef_run).to_not create_template_if_missing("#{base_dir}/templates/foo.conf.erb.erb") }
  end

  context 'with -s copying a source file' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }

    before do
      ChefCLI::Generator.add_attr_to_context(:content_source, '/src/foo.conf')
      allow(IO).to receive(:read).and_call_original
      allow(IO).to receive(:read).with('/src/foo.conf').and_return("listen 80\n")
    end

    it { expect(chef_run).to create_file_if_missing("#{base_dir}/templates/foo.conf.erb").with(content: "listen 80\n") }
    it { expect(chef_run).to_not create_template_if_missing("#{base_dir}/templates/foo.conf.erb") }
  end

  context 'with -s onto a file that already exists' do
    before do
      ChefCLI::Generator.add_attr_to_context(:content_source, '/src/foo.conf')
      allow(IO).to receive(:read).and_call_original
      allow(IO).to receive(:read).with('/src/foo.conf').and_return("listen 80\n")
    end

    it 'warns that the file was left alone' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with("#{base_dir}/templates/foo.conf.erb").and_return(true)
      expect { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }.to output(
        %r{#{base_dir}/templates/foo.conf.erb already exists and was not replaced; remove it first to copy -s /src/foo.conf}
      ).to_stderr
    end

    it 'says nothing when the file is new' do
      expect { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }.to_not output(
        /already exists/
      ).to_stderr
    end
  end
end
