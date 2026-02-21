# frozen_string_literal: true

require "spec_helper"

RSpec.describe Persey::Node do
  describe "#[]" do
    it "accesses values by key" do
      node = described_class.new({ name: "test", port: 3000 })

      expect(node[:name]).to eq("test")
      expect(node[:port]).to eq(3000)
    end
  end

  describe "#to_hash" do
    it "returns a hash representation" do
      node = described_class.new({ name: "test", database: { host: "localhost" } })

      expect(node.to_hash).to eq({ name: "test", database: { host: "localhost" } })
    end
  end

  describe "#each_pair" do
    it "iterates over key-value pairs" do
      node = described_class.new({ a: 1, b: 2 })
      pairs = []

      node.each_pair { |k, v| pairs << [k, v] }

      expect(pairs).to eq([[:a, 1], [:b, 2]])
    end
  end

  describe "missing methods" do
    it "returns nil for undefined keys on root node" do
      node = described_class.new({ name: "test" })

      expect(node.undefined_key).to be_nil
    end

    it "delegates missing methods from nested node to root" do
      node = described_class.new({ scheme: "https", nested: { host: "example.com" } })

      expect(node.nested.scheme).to eq("https")
    end
  end
end
