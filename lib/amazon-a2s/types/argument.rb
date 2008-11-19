class Argument
  include ROXML

  xml_reader :name, :attr
  xml_reader :value, :attr
end