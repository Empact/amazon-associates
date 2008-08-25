require 'rubygems'
require 'active_support'

class Object # http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
  def meta_def name, &blk
    (class << self; self; end).instance_eval { define_method name, &blk }
  end
end

class OpenHash < Hash
  def method_missing_with_attributes_query(meth, *args)
    fetch(meth) do
      method_missing_without_attributes_query(meth)
    end
  end
  alias_method_chain :method_missing, :attributes_query  
end

class Float
  def whole?
    (self % 1) < 0.0001
  end
end

class Hash
  def each_key!(&block)
    each_key do |key|
      val = delete(key)
      new_key = yield key
      store(new_key, val)
    end
  end
  
  def map_keys!(keys)
    keys.each_pair do |new, old|
      store(new, delete(old)) if has_key?(old)
    end
  end
end