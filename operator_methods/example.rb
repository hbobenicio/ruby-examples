#!/usr/bin/env ruby

class Pessoa
  @@populacao = 0

  attr_accessor :nome

  def initialize(nome)
    @nome = nome
    @@populacao += 1
  end

  def <=>(pessoa)
    @nome <=> pessoa.nome
  end

  def self.populacao
    @@populacao
  end
end

pessoas = []
pessoas << Pessoa.new "Pedro"
pessoas << Pessoa.new "Maria"
pessoas << Pessoa.new "Joao"

puts "%d pessoas foram criadas. Sao elas:" % Pessoa.populacao
[pedro, maria, joao].sort.each do |pessoa|
  puts pessoa.nome
end
