module DslAccessor
  def self.included(base)
    base.extend Macros
  end

  module Macros
    def dsl_accessor(*keys)
      keys.map(&:to_s).each do |k|
        class_eval <<-ACCESSORS
          attr_writer :#{k}
          def #{k}(v = nil)
            if v
              @#{k} = v
            else
              @#{k}
            end
          end
        ACCESSORS
      end
    end
  end
end