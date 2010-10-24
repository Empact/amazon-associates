require 'active_support'
require 'active_support/core_ext/enumerable'

require 'active_model'

class Object # http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
  def meta_def name, &blk
    (class << self; self; end).instance_eval { define_method name, &blk }
  end
end

class OpenHash < Hash
  def method_missing(meth, *args)
    fetch(meth) do
      super
    end
  end
end

class Float
  def whole?
    (self % 1) < 0.0001
  end
end

class Hash
  def rekey!(keys)
    keys.each_pair do |old, new|
      store(new, delete(old)) if has_key?(old)    
    end
  end
end