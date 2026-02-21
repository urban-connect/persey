# frozen_string_literal: true

require "spec_helper"

RSpec.describe Persey::Proxy do
  describe "#result" do
    it "collects simple key-value pairs" do
      proxy = described_class.new(proc { name "test" })

      expect(proxy.result).to eq({name: "test"})
    end

    it "collects nested blocks as hashes" do
      proxy = described_class.new(proc {
        database do
          host "localhost"
        end
      })

      expect(proxy.result).to eq({database: {host: "localhost"}})
    end
  end
end
