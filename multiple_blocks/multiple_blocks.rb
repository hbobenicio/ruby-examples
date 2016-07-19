#!/usr/bin/env ruby

class Cup
  attr_accessor :state

  def initialize
    @state = "empty"
  end
end

def with_cup(waiter_block, client_block)
  cup = Cup.new
  waiter_block.call cup
  client_block.call cup
end

waiter_block = lambda do |cup|
  puts "Filling the #{cup.state} cup."
  cup.state = "filled"
end

client_block = lambda do |cup|
  puts "Drinking the #{cup.state} cup."
  cup.state = "empty"
end

with_cup(waiter_block, client_block)
with_cup lambda{|cup| puts "1" }, lambda{|cup| puts "2" }

