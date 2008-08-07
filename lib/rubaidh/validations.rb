module Rubaidh
  module Validations
    module RegularExpressions
      module RegexStr
        Hostname = '([a-zA-Z0-9]{2,})(-([a-zA-Z0-9]+))*'.freeze
      end

      Hostname = /\A#{RegexStr::Hostname}\Z/
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def validates_hostname_format_of(*attr_names)
        options = attr_names.extract_options!

        format_configuration = { :with => Rubaidh::Validations::RegularExpressions::Hostname }
        format_configuration.update(options)
        validates_format_of *(attr_names + [format_configuration])

        length_configuration = { :within => 2..63 }
        length_configuration.update(options)
        validates_length_of *(attr_names + [length_configuration])
      end
    end
  end
end