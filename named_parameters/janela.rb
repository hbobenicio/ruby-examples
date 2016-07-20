#!/usr/bin/env ruby

def janela(x:, y:, w:, h:)
  puts "(%d, %d) - %d x %d" % [x, y, w, h]
end

janela x:10, y:10, w:400, h:600

janela w:400, h:600, x:10, y:15

