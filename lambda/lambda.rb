#!/usr/bin/env ruby

imprimir_elem = lambda do |elem|
  puts elem
end

[1, 2, 3, 4].each &imprimir_elem

puts "--------"

def para_cada(lista, func)
  lista.each &func
end

para_cada [1, 2, 3, 4], imprimir_elem
