#!/usr/bin/env ruby

# http://ruby-doc.org/stdlib-2.3.0/libdoc/observer/rdoc/Observable.html
#
# The Observer pattern (also known as publish/subscribe) provides a simple mechanism for
# one object to inform a set of interested third-party objects when its state changes.

require 'observer'

# Classe observável
class Clock
  include Observable
  
  def initialize
    @seconds = 0
  end
  
  def start
    loop do
      sleep 1
      
      # Alterando o objeto
      changed
      @seconds += 1
      
      # Notificando os observadores
      notify_observers(@seconds)
    end
  end
  
end

# Classe observadora
class Treinador
  
  def initialize(clock)
    clock.add_observer(self)
  end
  
  def update(seconds)
    puts "[TREINADOR]: Corre mais, só se passaram #{seconds} segundos!"
  end
end

# Classe observadora
class Atleta
  
  def initialize(clock)
    clock.add_observer(self)
  end
  
  def update(seconds)
    puts "[ATLETA]: Estou cansando, já se passaram #{seconds} segundos!"
  end
end

clock = Clock.new

treinador = Treinador.new(clock)
atleta = Atleta.new(clock)

clock.start

# Exemplo meramente didático... se quiser um "clock" de verdade
# o ruby já possui a classe Timer para este fim :)