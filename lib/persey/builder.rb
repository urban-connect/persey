# frozen_string_literal: true

module Persey
  class Builder
    def initialize(env, block)
      @current_env = env
      @envs = {}
      instance_eval(&block)
    end

    def result(env = nil, visited = Set.new)
      e = env || @current_env
      raise ArgumentError, "Circular parent dependency detected: '#{e}'" if visited.include?(e)

      edata = @envs[e]
      raise ArgumentError, "Undefined environment '#{e}'" if edata.nil?

      visited.add(e)
      current_config = edata[:block] ? Proxy.new(edata[:block]).result : {}

      if (parent = edata[:options][:parent])
        parent_config = result(parent, visited)
        current_config = deep_merge(parent_config, current_config)
      end

      current_config
    end

    private def env(name, options = {}, &block)
      @envs[name.to_sym] = {options: options, block: block}
    end

    private def deep_merge(target, source)
      merged = target.dup
      source.each_pair do |k, v|
        tv = merged[k]
        merged[k] = (tv.is_a?(Hash) && v.is_a?(Hash)) ? deep_merge(tv, v) : v
      end
      merged
    end
  end
end
