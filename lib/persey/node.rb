# frozen_string_literal: true

module Persey
  class Node
    def initialize(hash, root: nil)
      @hash = hash
      @root = root || self

      hash.each_pair do |key, value|
        wrapped = value.is_a?(Hash) ? Node.new(value, root: @root) : value

        define_singleton_method(key.to_sym) do
          wrapped.is_a?(Proc) ? instance_exec(&wrapped) : wrapped
        end
      end

      deep_freeze(@hash)
    end

    def [](key)
      @hash[key]
    end

    def to_hash
      deep_to_hash(@hash)
    end

    def each_pair(&block)
      @hash.each_pair do |key, value|
        wrapped = value.is_a?(Hash) ? Node.new(value, root: @root) : value
        yield key, wrapped
      end
    end

    def inspect
      "#<Persey::Node #{@hash.inspect}>"
    end

    def method_missing(meth, *args, &blk)
      return nil if @root.equal?(self)
      return @root.public_send(meth, *args, &blk) if @root.respond_to?(meth)

      nil
    end

    def respond_to_missing?(meth, include_private = false)
      return false if @root.equal?(self)

      @root.respond_to?(meth)
    end

    private def deep_to_hash(hash)
      result = {}
      hash.each_pair do |key, value|
        result[key] = value.is_a?(Hash) ? deep_to_hash(value) : value
      end
      result
    end

    private def deep_freeze(obj)
      case obj
      when Hash
        obj.each_value { |v| deep_freeze(v) }
        obj.freeze
      when String, Array
        obj.freeze
      end
    end
  end
end
