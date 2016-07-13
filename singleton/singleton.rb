#!/usr/bin/env ruby

require 'singleton'

class MySingleton
  include Singleton
  
  attr_accessor :info
end

begin
  MySingleton.new
rescue NoMethodError
  puts "Singleton classes have private constructors."
end

MySingleton.instance.info = "Hello, Singleton"

test = MySingleton.instance
test.info = "New value, same instance"

if MySingleton.instance.info == test.info
  puts "Singleton ok!"
else
  puts "Something went wrong..."
end

