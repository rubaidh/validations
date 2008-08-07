require 'rubaidh/validations'

ActiveRecord::Base.class_eval do
  include Rubaidh::Validations
end