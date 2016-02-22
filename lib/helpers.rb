module Helpers
  SifCharValues = {
    "O"  => "Optional", 
    "M"  => "Mandatory", 
    "OR" => "Optional Required", 
    "MR" => "Mandatory Required",
    "C"  => "Conditional"
  }
  
  def h(text)
    Rack::Utils.escape_html(text)
  end
  
  def attributeValue(key, value)
    case key
    when 'type' then "<code>#{value}</code>"
    else value
    end
  end
  
  def annotationValue(key, value)
    case key
    when /\A#{URI::regexp(['http', 'https'])}\z/
      "<a class=\"ceds\" href=\"#{value}\" target=\"_blank\">#{value}</a>"
    when 'sifChar'
      SifCharValues[value] || value
    else
      value
    end
  end
end
