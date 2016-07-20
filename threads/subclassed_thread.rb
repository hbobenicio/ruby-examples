#!/usr/bin/env ruby

class MyThread < Thread
  def initialize(x, y)
    super(x, y) do |val1, val2|
      Thread.stop
      puts "In thread..."
      puts val1, val2
      puts
    end
  end
end

t = MyThread.new("hello", "world")
puts "main program"
puts
sleep(2)

t.run

t.join
sleep(2)
puts "main program ending..."

