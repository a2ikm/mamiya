require 'spec_helper'
require 'tmpdir'

require 'mamiya/script'
require 'mamiya/dsl'

describe Mamiya::Script do
  it "inherits Mamiya::DSL" do
    expect(described_class.ancestors).to include(Mamiya::DSL)
  end

  subject(:script) { described_class.new }
  let(:log) { [] }

  let(:logger) {
    double("logger").tap do |_|
      _.stub(:[]) { _ }
      %i(info warn debug error).each do |severity|
        _.stub(severity) { |*args| log << [severity, *args]; _ }
      end
    end
  }

  before do
    script.set :logger, logger
  end

  describe "#run" do
    it "runs command" do
      tmpdir = Dir.mktmpdir('akane-script-spec')
      testee = File.join(tmpdir, 'test')

      expect {
        script.run("touch", testee)
      } \
        .to change { File.exists?(testee) } \
        .from(false).to(true)
    end

    context "when the command failed" do
      it "logs error" do
        begin
          script.run("false")
        rescue Mamiya::Script::CommandFailed
        end
        expect(log.map(&:first)).to include(:error)
      end

      it "raises error" do
        expect {
          script.run("false")
        }.to raise_error(Mamiya::Script::CommandFailed)
      end

      context "with allow_failure" do
        it "ignores error" do
          expect {
            script.run("false", allow_failure: true)
          }.not_to raise_error
        end
      end
    end

    it "logs command as information" do
      script.run("echo", "foo", "bar'", " baz")
      expect(log).to include([:info, "$ echo foo bar\\' \\ baz"])
    end

    it "logs stdout as info" do
      script.run("echo", "foo")
      expect(log).to include([:info, "foo"])
    end

    it "logs stderr as warn" do
      script.run("ruby", "-e", "warn 'bar'")
      expect(log).to include([:warn, "bar"])
    end

    it "returns captured output as String" do
      out = script.run("ruby", "-e", "puts 'foo'; warn 'bar'")
      expect(out).to match(/^foo$/)
      expect(out).to match(/^bar$/)
    end
  end
end
