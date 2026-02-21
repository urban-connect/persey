# frozen_string_literal: true

module Persey
  class Proxy
    attr_reader :result

    def initialize(block)
      @result = {}
      instance_eval(&block)
    end

    def method_missing(key, value = nil, &block)
      @result[key] = block_given? ? self.class.new(block).result : value
    end

    def respond_to_missing?(*)
      true
    end
  end
end
