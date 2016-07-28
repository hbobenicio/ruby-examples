#!/usr/bin/env ruby

class SharkAppeared < StandardError
  attr_accessor :shark_name

  def initialize(shark_name="Unknown")
    super shark_name
    @shark_name = shark_name
  end
end

begin
  puts "Going surfing"

	puts "Is that a shark?!?"
  shark = gets.chomp
 	raise SharkAppeared.new("Great White Shark") if shark == "yes"

  puts "Wait for waves."

rescue SharkAppeared => e
  puts "Screem: WATCH OUT...SHARK!!!! IT'S A #{e.shark_name.upcase}!"
else
  puts "Get some good waves"
ensure
  puts "Then go gome"
end

