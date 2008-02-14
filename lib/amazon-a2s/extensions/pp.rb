require 'pp'
require 'stringio'

class Object
  def pp_to_s
    old_out = $stdout
    begin
      $stdout = s = StringIO.new
      pp self
    ensure
      $stdout = old_out
    end
    s.string
  end
end
