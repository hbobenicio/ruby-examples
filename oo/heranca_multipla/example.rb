#!/usr/bin/env ruby

# Ruby doen't support multiple inheritance.
# But this effect can be achieved using modules

module AnimalTerrestre
  def andar
    puts "Andando..."
  end
end

module AnimalAquatico
  def nadar
    puts "Nadando..."
  end
end

class AnimalAnfibio
  include AnimalTerrestre
  include AnimalAquatico

  attr_accessor :ambiente

  def initialize(ambiente)
    @ambiente = ambiente
  end

  def mudar_ambiente
    @ambiente = (@ambiente == :agua) ? :terra : :agua
  end

  def mover
    if @ambiente == :agua
      nadar
    else
      andar
    end
  end
end

sapo = AnimalAnfibio.new :terra

sapo.mover
sapo.mudar_ambiente
sapo.mover

