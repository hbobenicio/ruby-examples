#!/usr/bin/env ruby

# map/collect

squares = [1, 2, 3, 4, 5].map { |item| item * item }
x = ["a", "b", "c"].collect { |word| "#{word}." }
x = (1..50).map do |item|
  (item % 4 == 0) ? "pin" : item
end

# reduce (:+, :*, ...)

sum = [1, 2, 3, 4, 5].reduce(:+)

def fact(n)
  (1..n).reduce(1, :*)
end

# inject

# select/reject
evens = (1..100).select { |x| x.even? }
odds = (1..100).reject { |x| x.even? }

