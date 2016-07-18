#!/usr/bin/env ruby

require_relative 'event_module'

class Button
  include EventModule
  
  def click
    emit :click
  end
end

button = Button.new
button.connect(:click) do
  puts "Button clicked!"
end
button.click
