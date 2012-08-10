require 'spec_helper'

describe Typhoeus::Requests::Stubbable do
  let(:url) { "localhost:3001" }
  let(:request) { Typhoeus::Request.new(url) }
  let(:response) { Typhoeus::Response.new }

  before { Typhoeus.stub(url).and_return(response) }
  after { Typhoeus::Expectation.clear }

  describe "#queue" do
    it "checks expactations" do
      request.run
    end

    context "when expectation found" do
      it "assigns response" do
        request.run
        expect(request.response).to be(response)
      end

      it "executes callbacks" do
        request.should_receive(:execute_callbacks)
        request.run
      end
    end
  end
end