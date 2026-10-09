require_relative '../../spec_helper'
require_relative '../../../libraries/helpers'
require 'tmpdir'

describe CodeGenerator::Helpers do
  subject { Object.new.extend(described_class) }

  describe '#osl_short_name' do
    it { expect(subject.osl_short_name('osl-foo-bar')).to eq 'foo_bar' }
    it { expect(subject.osl_short_name('proj-foo')).to eq 'foo' }
    it { expect(subject.osl_short_name('base')).to eq 'base' }
  end

  describe '#osl_camelize' do
    it { expect(subject.osl_camelize('osl-foo_bar')).to eq 'OslFooBar' }
  end

  describe '#osl_cookbook_dir!' do
    around do |example|
      Dir.mktmpdir do |dir|
        @dir = dir
        example.run
      end
    end

    it 'names the cookbook from metadata.rb when chef-cli was given .' do
      FileUtils.mkdir_p(File.join(@dir, 'osl-dot'))
      File.write(File.join(@dir, 'osl-dot', 'metadata.rb'), "name 'osl-dot'\n")
      context = Struct.new(:cookbook_root, :cookbook_name).new(File.join(@dir, 'osl-dot'), '.')
      expect(subject.osl_cookbook_dir!(context)).to eq File.join(@dir, 'osl-dot', '.')
      expect(context.cookbook_name).to eq 'osl-dot'
    end

    it 'falls back to the expanded directory name without metadata.rb' do
      FileUtils.mkdir_p(File.join(@dir, 'osl-bare'))
      context = Struct.new(:cookbook_root, :cookbook_name).new(File.join(@dir, 'osl-bare'), '.')
      subject.osl_cookbook_dir!(context)
      expect(context.cookbook_name).to eq 'osl-bare'
    end
  end

  describe '#osl_fixture' do
    around do |example|
      Dir.mktmpdir do |dir|
        @dir = dir
        example.run
      end
    end

    def fixture(path, name = nil)
      FileUtils.mkdir_p(File.join(@dir, path))
      File.write(File.join(@dir, path, 'metadata.rb'), name ? "name '#{name}'\n" : '')
    end

    it 'creates <short>_test when there is none' do
      expect(subject.osl_fixture(@dir, 'osl-foo')).to eq(
        name: 'foo_test', dir: "#{@dir}/test/cookbooks/foo_test", exists: false
      )
    end

    it 'reuses the only fixture, named from its metadata' do
      fixture('test/fixtures/cookbooks/osl-foo-test', 'foo-fixture')
      expect(subject.osl_fixture(@dir, 'osl-foo')).to eq(
        name: 'foo-fixture', dir: "#{@dir}/test/fixtures/cookbooks/osl-foo-test", exists: true
      )
    end

    it 'prefers a conventionally named fixture among several' do
      fixture('test/cookbooks/web1-test')
      fixture('test/cookbooks/foo-test')
      expect(subject.osl_fixture(@dir, 'proj-foo')).to include(name: 'foo-test', exists: true)
    end

    it 'refuses to guess between several unconventional fixtures' do
      fixture('test/cookbooks/web1-test')
      fixture('test/cookbooks/web2-test')
      expect { subject.osl_fixture(@dir, 'proj-foo') }.to raise_error(
        RuntimeError, /Several fixture cookbooks \(web1-test, web2-test\); pick one with -a fixture=<name>/
      )
    end

    it 'honours an override that exists' do
      fixture('test/cookbooks/web1-test')
      fixture('test/cookbooks/web2-test')
      expect(subject.osl_fixture(@dir, 'proj-foo', 'web2-test')).to include(name: 'web2-test', exists: true)
    end

    it 'creates an override that does not exist' do
      expect(subject.osl_fixture(@dir, 'proj-foo', 'bar_test')).to eq(
        name: 'bar_test', dir: "#{@dir}/test/cookbooks/bar_test", exists: false
      )
    end
  end

  describe '#osl_berksfile_with_fixture' do
    head = "source 'https://supermarket.osuosl.org'\n\nsolver :ruby, :required\n\n"

    it 'inserts above metadata' do
      expect(subject.osl_berksfile_with_fixture("#{head}metadata\n", 'foo_test', 'test/cookbooks/foo_test')).to eq(
        "#{head}cookbook 'foo_test', path: 'test/cookbooks/foo_test'\n\nmetadata\n"
      )
    end

    it 'inserts after the last path line' do
      content = "#{head}cookbook 'a-test', path: 'test/cookbooks/a-test'\n\nmetadata\n"
      expect(subject.osl_berksfile_with_fixture(content, 'foo_test', 'test/cookbooks/foo_test')).to eq(
        "#{head}cookbook 'a-test', path: 'test/cookbooks/a-test'\n" \
        "cookbook 'foo_test', path: 'test/cookbooks/foo_test'\n\nmetadata\n"
      )
    end

    it 'leaves a Berksfile that already lists the fixture alone' do
      content = "#{head}cookbook 'foo_test', path: 'test/cookbooks/foo_test'\n\nmetadata\n"
      expect(subject.osl_berksfile_with_fixture(content, 'foo_test', 'test/cookbooks/foo_test')).to be_nil
    end
  end
end
