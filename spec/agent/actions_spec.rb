require 'spec_helper'

require 'json'
require 'villein/event'

require 'mamiya/agent'
require 'mamiya/agent/actions'

require_relative '../support/dummy_serf.rb'

describe Mamiya::Agent::Actions do
  let(:serf) { DummySerf.new }

  let(:config) do
    {serf: {agent: {rpc_addr: '127.0.0.1:17373', bind: '127.0.0.1:17946'}}}
  end

  before do
    allow(Villein::Agent).to receive(:new).and_return(serf)
  end

  subject(:agent) { Mamiya::Agent.new(config) }


  describe "#distribute" do
    it "sends fetch request" do
      expect(agent).to receive(:trigger).with('task', task: 'fetch', application: 'app', package: 'pkg', coalesce: false)

      agent.distribute('app', 'pkg')
    end
  end
end
