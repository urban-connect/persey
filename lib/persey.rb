# frozen_string_literal: true

require_relative "persey/proxy"
require_relative "persey/builder"
require_relative "persey/node"

module Persey
  def self.init(env, &block)
    e = env.is_a?(Symbol) ? env : env.to_sym
    builder = Builder.new(e, block)
    @config = Node.new(builder.result)
  end

  def self.config
    raise "Please, init config before usage" if @config.nil?

    @config
  end

  def self.reset!
    @config = nil
  end
end
