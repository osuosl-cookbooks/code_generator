require_relative '../../spec_helper'

%w(input policyfile profile repo waiver).each do |command|
  describe "code_generator::#{command}" do
    include_context 'common_stubs'
    before { allow(Kernel).to receive(:exit!) }

    it 'refuses on stderr with a pointer to the README and exits 1' do
      expect { ChefSpec::SoloRunner.new(ALMA_10).converge(described_recipe) }.to output(
        /`cinc generate #{command}` is not supported by the OSL code_generator/
      ).to_stderr
      expect(Kernel).to have_received(:exit!).with(1)
    end
  end
end
