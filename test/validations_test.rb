ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test_help'

class DummyActiveRecordBase
  def save
    false
  end

  def save!
    raise(RecordNotSaved)
  end

  def new_record?
    true
  end

  def self.base_class
    self
  end

  def self.human_attribute_name(attr)
    attr
  end

  include ActiveRecord::Validations
  include Rubaidh::Validations
end


class ValidatesHostnameTest < ActiveSupport::TestCase
  class Model < DummyActiveRecordBase
    attr_accessor :hostname
    validates_hostname_format_of :hostname
  end

  test "the model can be instantiated" do
    assert Model.new
  end

  test "the model correctly identifies some valid hostnames" do
    valid_hostnames = [
      'foo',
      'bar',
      'foo-bar',
      '1-2-3-4',
      'tc',
      't' * 63
    ]

    valid_hostnames.each do |valid_hostname|
      model = Model.new
      model.hostname = valid_hostname
      assert model.valid?, "Hostname '#{valid_hostname}' should be valid"
    end
  end

  test "the validation correctly identifies some invalid hostnames" do
    invalid_hostnames = [
      ['-foo',        'starts with a "-"'],
      ['foo-',        'ends with a "-"'],
      ['f',           'too short'],
      ['f'*64,        'too long'],
      ['f@b',         'contains an invalid character'],
      ['f_ab',        'contains an invalid character'],
      ['example.com', 'contains an invalid character (a hostname is not a fqdn)']
    ]

    invalid_hostnames.each do |invalid_hostname, reason|
      model = Model.new
      model.hostname = invalid_hostname
      assert !model.valid?, "Hostname '#{invalid_hostname}' should not be valid: #{reason}"
    end
  end
end
