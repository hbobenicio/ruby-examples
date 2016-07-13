#!/usr/bin/env ruby

require 'singleton'

# Declaring a singleton class
class MySingleton
  include Singleton
  
  attr_accessor :info

  def initialize
    puts "Singleton constructor is called just once."
  end
end

# Trying to instanciate it manually will raise an exception
begin
  MySingleton.new
rescue NoMethodError
  puts "Singleton classes have private constructors."
end

# Testing it
MySingleton.instance.info = "Hello, Singleton"

test = MySingleton.instance
test.info = "New value, same instance"

if MySingleton.instance.info == test.info
  puts "Singleton ok!"
else
  puts "Something went wrong..."
end

