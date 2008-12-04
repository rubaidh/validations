module Rubaidh
  module Validations
    module RegularExpressions
      module RegexStr
        Hostname = '[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]'.freeze
        FullyQualifiedDomainName = "#{Hostname}(\\.#{Hostname})+\\.?".freeze

        EmailAddressLocalPartSpecialCharacters = Regexp.escape('!#$%&\'*+-/=?^_`{|}~').freeze
        EmailAddressLocalPartUnquoted = "[[:alnum:]#{EmailAddressLocalPartSpecialCharacters}][[:alnum:]#{EmailAddressLocalPartSpecialCharacters}\.]*".freeze
        EmailAddressLocalPartQuoted = '[\x00-\xFF]+'.freeze
        EmailAddressLocalPart = "(#{EmailAddressLocalPartUnquoted}|\"#{EmailAddressLocalPartQuoted}\")".freeze
        EmailAddress = "#{EmailAddressLocalPart}@#{FullyQualifiedDomainName}".freeze

        Protocol = "https?".freeze
        OptionalPort = "(:[0-9]{1,5})?".freeze
        OptionalPath = "([[:alnum:]._~/-]|%[0-9a-fA-F]+)*"
      end

      Hostname = /\A#{RegexStr::Hostname}\Z/.freeze
      FullyQualifiedDomainName = /\A#{RegexStr::FullyQualifiedDomainName}\Z/.freeze
      EmailAddress = /\A#{RegexStr::EmailAddress}\Z/.freeze

      # FIXME: We should be checking for query strings and fragments here, but
      # pragmatism has won out today.
      Url = /\A#{RegexStr::Protocol}:\/\/#{RegexStr::FullyQualifiedDomainName}#{RegexStr::OptionalPort}#{RegexStr::OptionalPath}/.freeze
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

      def validates_url_format_of(*attr_names)
        options = attr_names.extract_options!
        configuration = { :with => Rubaidh::Validations::RegularExpressions::Url }
        configuration.update(options)
        validates_format_of *(attr_names + [configuration])
      end
    end
  end
end