#!/usr/bin/env ruby

# Basic syntax.
begin
  puts 10 / 0
rescue
  puts "Everything is safe now"
end

# Basic syntax. Generic error handling
begin
  puts 10 / 0
rescue => e
  puts "Everything is safe now. But this happened:"
  puts "Exception message: #{e.message}"
  puts "Exception stacktrace:"
  puts e.backtrace
end

# Full syntax
begin
  # something which might raise an exception
rescue SomeExceptionClass => some_variable
  # code that deals with some exception
rescue SomeOtherException => some_other_variable
  # code that deals with some other exception
else
  # code that runs only if *no* exception was raised
ensure
  # ensure that this code always runs, no matter what
end

# Inside a function, you don't need a 'begin' block.
def safe_division(x, y)
  x / y
rescue ZeroDivisionError
  puts "Never divide by zero!"
end
safe_division(10, 0)

# This is how you create a custom Exception. Just subclass another one.
# It's preferable that you inherits from StandardError instead of the
# generic Exception
class MyCustomError < StandardError
end

begin
  puts "Doing stuff..."
  raise MyCustomError, "MyCustomError: You messed things up!"
rescue => e
  puts "Something went wrong: #{e.message}"
else
  puts "what else to do?"
ensure
	puts "This will always be executed."
end

=begin
This is the Ruby standard error (exception) hierarchy:

Exception
 NoMemoryError
 ScriptError
   LoadError
   NotImplementedError
   SyntaxError
 SignalException
   Interrupt
 StandardError
   ArgumentError
   IOError
     EOFError
   IndexError
   LocalJumpError
   NameError
     NoMethodError
   RangeError
     FloatDomainError
   RegexpError
   RuntimeError
   SecurityError
   SystemCallError
   SystemStackError
   ThreadError
   TypeError
   ZeroDivisionError
 SystemExit
 fatal

=end
