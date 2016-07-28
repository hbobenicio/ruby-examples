#!/usr/bin/env ruby

module EnumerableSum
  def sum
    total = 0
    each do |value|
      total = total + value
    end
    total
  end
end

class Array
  include EnumerableSum
end

class Range
  include EnumerableSum
end

