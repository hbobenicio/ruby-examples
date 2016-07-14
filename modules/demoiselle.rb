#!/usr/bin/env ruby

# http://ruby-doc.com/docs/ProgrammingRuby/html/tut_modules.html

module Demoiselle

  # Accessible externally with Demoiselle::VERSION
  VERSION = "3.0"

  # This function will be exported and accessible externally
  # with Demoiselle.say_hello
  def self.say_hello
    puts "Hello, Ruby Modules!"
  end

  # This function will also be exported.
  # Either the package name (in this case 'Demoiselle') or
  # the keyword 'self' can be used to export symbols.
  def Demoiselle.transactional
    puts "Beginning transaction."
    yield
    puts "Commiting transaction."
    flush_transaction
  end

  # This won't be accessible though.
  def flush_transaction
    puts "Flushing Transaction."
  end

end

module Demoiselle2
  class << self
  private
    def flush_transaction
      puts "Flushing transaction."
    end

  public
    def transactional
      puts "Begin transaction."
      yield
      puts "Commit transaction."
      flush_transaction
    end
  end
end

