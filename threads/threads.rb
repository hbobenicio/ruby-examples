#!/usr/bin/env ruby

# http://ruby-doc.org/core-2.3.0/Thread.html
# http://ruby-doc.org/core-2.3.0/ConditionVariable.html

require 'thread'

def time_now
  Time.now.strftime("%d/%m/%Y %H:%M:%S")
end

def sync_puts(mutex, msg)
  mutex.synchronize do
    puts msg
  end
end

mutex = Mutex.new

produtor = Thread.new do
  
  10.times do |cont|
    msg = "[%10s | %s] Produzindo pela %da vez." % ["PRODUTOR", time_now, cont+1]
    sync_puts(mutex, msg)
    
    sleep Random.new.rand(1..3)
  end
  
  puts "[%10s | %s] Produção finalizada." % ["PRODUTOR", time_now]
end

consumidor = Thread.new do
  10.times do |cont|
    msg = "[%10s | %s] Consumindo pela %da vez." % ["CONSUMIDOR", time_now, cont+1]
    sync_puts(mutex, msg)
    
    sleep Random.new.rand(3..5)
  end
  
  puts "[%10s | %s] Consumo finalizado." % ["CONSUMIDOR", time_now]
end


produtor.join
consumidor.join
