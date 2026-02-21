# frozen_string_literal: true

require "spec_helper"

RSpec.describe Persey::Builder do
  describe "#result" do
    it "builds config for the given environment" do
      builder = described_class.new(:test, proc {
        env :test do
          app_name "my_app"
        end
      })

      expect(builder.result).to eq({app_name: "my_app"})
    end

    it "deep merges parent config" do
      builder = described_class.new(:child, proc {
        env :parent do
          database do
            host "localhost"
            port 5432
          end
        end

        env :child, parent: :parent do
          database do
            port 3306
          end
        end
      })

      expect(builder.result).to eq({database: {host: "localhost", port: 3306}})
    end

    it "raises ArgumentError for circular parent dependencies" do
      builder = described_class.new(:a, proc {
        env :a, parent: :b
        env :b, parent: :a
      })

      expect { builder.result }.to raise_error(ArgumentError, /Circular parent dependency detected/)
    end

    it "returns empty hash for environment without block" do
      builder = described_class.new(:child, proc {
        env :parent do
          app_name "my_app"
        end

        env :child, parent: :parent
      })

      expect(builder.result).to eq({app_name: "my_app"})
    end
  end
end
