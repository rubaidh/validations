module Rubaidh
  module Validations
    module RegularExpressions
      module RegexStr
        Hostname = '[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]'.freeze
        FullyQualifiedDomainName = "#{Hostname}(\\.#{Hostname})+\\.?".freeze

        EmailAddressLocalPartSpecialCharacters = Regexp.escape('!#$%&\'*+-/=?^_`{|}~')
        EmailAddressLocalPartUnquoted = "[[:alnum:]#{EmailAddressLocalPartSpecialCharacters}][[:alnum:]#{EmailAddressLocalPartSpecialCharacters}\.]*"
        EmailAddressLocalPartQuoted = '[\x00-\xFF]+'
        EmailAddressLocalPart = "(#{EmailAddressLocalPartUnquoted}|\"#{EmailAddressLocalPartQuoted}\")"
        EmailAddress = "#{EmailAddressLocalPart}@#{FullyQualifiedDomainName}".freeze
      end

      Hostname = /\A#{RegexStr::Hostname}\Z/.freeze
      FullyQualifiedDomainName = /\A#{RegexStr::FullyQualifiedDomainName}\Z/.freeze
      EmailAddress = /\A#{RegexStr::EmailAddress}\Z/.freeze
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

      def validates_fully_qualified_domain_name_format_of(*attr_names)
        options = attr_names.extract_options!

        format_configuration = { :with => Rubaidh::Validations::RegularExpressions::FullyQualifiedDomainName }
        format_configuration.update(options)
        validates_format_of *(attr_names + [format_configuration])

        length_configuration = { :within => 5..255 }
        length_configuration.update(options)
        validates_length_of *(attr_names + [length_configuration])
      end

      def validates_email_address_format_of(*attr_names)
        options = attr_names.extract_options!
        configuration = { :with => Rubaidh::Validations::RegularExpressions::EmailAddress }
        configuration.update(options)
        validates_format_of *(attr_names + [configuration])
      end
    end
  end
end