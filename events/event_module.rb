#!/usr/bin/env ruby

module EventModule
  attr_accessor :events_table
  
  def connect(event, &slot_block)
    @events_table ||= {}
    
    if @events_table[event].nil?
      @events_table[event] = [slot_block]
    else
      @events_table[event] << slot_block
    end
  end
  
  def emit(event)
    @events_table[event].each do |slot_block|
      slot_block.call
    end
  end
end