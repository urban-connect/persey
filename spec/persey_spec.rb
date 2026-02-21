# frozen_string_literal: true

require "spec_helper"

RSpec.describe Persey do
  after do
    described_class.reset!
  end

  describe ".init" do
    it "initializes config for the given environment" do
      described_class.init(:test) do
        env :test do
          app_name "my_app"
        end
      end

      expect(described_class.config.app_name).to eq("my_app")
    end

    it "converts string environment to symbol" do
      described_class.init("test") do
        env :test do
          app_name "my_app"
        end
      end

      expect(described_class.config.app_name).to eq("my_app")
    end
  end

  describe ".config" do
    context "when config is not initialized" do
      before { described_class.reset! }

      it "raises an error" do
        expect { described_class.config }.to raise_error("Please, init config before usage")
      end
    end
  end

  describe "nested configuration" do
    it "supports nested blocks" do
      described_class.init(:test) do
        env :test do
          database do
            host "localhost"
            port 5432
          end
        end
      end

      expect(described_class.config.database.host).to eq("localhost")
      expect(described_class.config.database.port).to eq(5432)
    end

    it "supports deeply nested blocks" do
      described_class.init(:test) do
        env :test do
          services do
            api do
              base_url "https://api.example.com"
            end
          end
        end
      end

      expect(described_class.config.services.api.base_url).to eq("https://api.example.com")
    end
  end

  describe "environment inheritance" do
    it "inherits values from parent environment" do
      described_class.init(:child) do
        env :parent do
          app_name "my_app"
          debug false
        end

        env :child, parent: :parent do
          debug true
        end
      end

      expect(described_class.config.app_name).to eq("my_app")
      expect(described_class.config.debug).to eq(true)
    end

    it "inherits nested values from parent environment" do
      described_class.init(:child) do
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
      end

      expect(described_class.config.database.host).to eq("localhost")
      expect(described_class.config.database.port).to eq(3306)
    end

    it "supports multi-level inheritance" do
      described_class.init(:grandchild) do
        env :base do
          app_name "my_app"
          mode "base"
        end

        env :middle, parent: :base do
          mode "middle"
          feature_x true
        end

        env :grandchild, parent: :middle do
          feature_y true
        end
      end

      expect(described_class.config.app_name).to eq("my_app")
      expect(described_class.config.mode).to eq("middle")
      expect(described_class.config.feature_x).to eq(true)
      expect(described_class.config.feature_y).to eq(true)
    end
  end

  describe "lambda values" do
    it "evaluates lambdas in the context of the root node" do
      described_class.init(:test) do
        env :test do
          scheme "https"
          host "example.com"
          base_url -> { "#{scheme}://#{host}" }
        end
      end

      expect(described_class.config.base_url).to eq("https://example.com")
    end
  end

  describe "undefined environment" do
    it "raises ArgumentError" do
      expect {
        described_class.init(:missing) do
          env :test do
            app_name "my_app"
          end
        end
      }.to raise_error(ArgumentError, "Undefined environment 'missing'")
    end
  end
end
