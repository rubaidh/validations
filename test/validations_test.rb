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
      assert model.errors.on(:hostname)
    end
  end
end

class ValidatesFullyQualifiedDomainNameTest < ActiveSupport::TestCase
  class Model < DummyActiveRecordBase
    attr_accessor :fully_qualified_domain_name
    validates_fully_qualified_domain_name_format_of :fully_qualified_domain_name
  end

  test "the model can be instantiated" do
    assert Model.new
  end

  test "the model correctly identifies some valid fully qualified domain names" do
    valid_fully_qualified_domain_names = [
      'example.com',
      'ff.com',
      "#{'f' * 63}.#{'g' * 63}.com",
      "example.com."
    ]

    valid_fully_qualified_domain_names.each do |valid_fully_qualified_domain_name|
      model = Model.new
      model.fully_qualified_domain_name = valid_fully_qualified_domain_name
      assert model.valid?, "Fully qualified domain name  '#{valid_fully_qualified_domain_name}' should be valid"
    end
  end

  test "the validation correctly identifies some invalid fully qualified domain names" do
    invalid_fully_qualified_domain_names = [
      ["#{'f' * 64}.com", 'while the overall length is in bounds, one of the hostname components is too long'],
      ["foo-.com",        'one of the domain components ends with a "-"'],
      ["info.",           'requires at least two hostname parts']
    ]

    invalid_fully_qualified_domain_names.each do |invalid_fully_qualified_domain_name, reason|
      model = Model.new
      model.fully_qualified_domain_name = invalid_fully_qualified_domain_name
      assert !model.valid?, "Fully qualified domain name '#{invalid_fully_qualified_domain_name}' should not be valid: #{reason}"
      assert model.errors.on(:fully_qualified_domain_name)
    end
  end
end

class ValidatesEmailAddressTest < ActiveSupport::TestCase
  class Model < DummyActiveRecordBase
    attr_accessor :email_address
    validates_email_address_format_of :email_address
  end

  test "the model can be instantiated" do
    assert Model.new
  end

  test "the model correctly identifies some valid email addresses" do
    valid_email_addresss = [
      'mathie@example.com',
      '#!/bin/sh@firedrake.org',
      '"foo bar"@example.org',
      'graeme.mathieson@acm.org',
    ]

    valid_email_addresss.each do |valid_email_address|
      model = Model.new
      model.email_address = valid_email_address
      assert model.valid?, "Email address '#{valid_email_address}' should be valid"
    end
  end

  test "the validation correctly identifies some invalid email addresses" do
    invalid_email_addresss = [
      ['@exmaple.org', "Must have a local part"],
      ['graeme.mathieson@', "Must contain a fully qualified domain name"],
      ['graeme@tullibardine', "Must contain a fully qualified domain name (not just a host name)"],
      ['foo bar@example.org', "Can't contain spaces"],
      ['.foo.bar@example.org', "Cannot start with a period"],
      ['""@example.org', "Must have something inside the quotes"],
      # FIXME ['foo..bar@exmapl.org', "Cannot contain two periods in a row in the local part"],
    ]

    invalid_email_addresss.each do |invalid_email_address, reason|
      model = Model.new
      model.email_address = invalid_email_address
      assert !model.valid?, "Email address '#{invalid_email_address}' should not be valid: #{reason}"
      assert model.errors.on(:email_address)
    end
  end
end