module Rubaidh
  module Validations
    module RegularExpressions
      module RegexStr
        Hostname = '[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]'.freeze
      end

      Hostname = /\A#{RegexStr::Hostname}\Z/.freeze
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def validates_hostname_format_of(*attr_names)
        options = attr_names.extract_options!

        configuration = { :with => Rubaidh::Validations::RegularExpressions::Hostname }
        configuration.update(options)
        validates_format_of *(attr_names + [configuration])
      end
    end
  end
end