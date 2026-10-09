require_relative '../../spec_helper'

describe 'code_generator::cookbook_file' do
  base_dir = '/tmp/test-cookbook'
  include_context 'common_stubs'
  before do
    ChefCLI::Generator.add_attr_to_context(:new_file_basename, 'bar')
    ChefCLI::Generator.add_attr_to_context(:content_source, nil)
  end

  context 'without a source file' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }

    it { expect(chef_run).to create_directory("#{base_dir}/files") }
    it { expect(chef_run).to create_template_if_missing("#{base_dir}/files/bar").with(source: 'cookbook_file.erb') }
  end

  context 'with -s copying a source file' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }

    before do
      ChefCLI::Generator.add_attr_to_context(:content_source, '/src/bar')
      allow(IO).to receive(:read).and_call_original
      allow(IO).to receive(:read).with('/src/bar').and_return("bar\n")
    end

    it { expect(chef_run).to create_file_if_missing("#{base_dir}/files/bar").with(content: "bar\n") }
    it { expect(chef_run).to_not create_template_if_missing("#{base_dir}/files/bar") }
  end

  context 'with -s onto a file that already exists' do
    before do
      ChefCLI::Generator.add_attr_to_context(:content_source, '/src/bar')
      allow(IO).to receive(:read).and_call_original
      allow(IO).to receive(:read).with('/src/bar').and_return("bar\n")
    end

    it 'warns that the file was left alone' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with("#{base_dir}/files/bar").and_return(true)
      expect { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }.to output(
        %r{#{base_dir}/files/bar already exists and was not replaced; remove it first to copy -s /src/bar}
      ).to_stderr
    end

    it 'says nothing when the file is new' do
      expect { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }.to_not output(
        /already exists/
      ).to_stderr
    end
  end
end
