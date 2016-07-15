#!/usr/bin/env ruby

########################################################################
# README
# ------
#
# Este script ruby fornece um mecanismo para facilitar a apuração do
# arquivo do STA de saldo do orçamento, utilizado pelo sigpro.
# Este script recebe como entrada o arquivo sigprosld_saldo_orcamento_ ,
# descompactado, corta as colunas desnecessárias da mesma forma que o
# script de carga e organiza colunas úteis em um hash para análise.
# Ao final, gera um arquivo de saída com os registros filtrados.
#
# INSTRUÇÕES DE USO
#
# 1) Caso ainda não tenha instalado em sua máquina, instale o ruby.
#    Melhor maneira (recomendada): utilizando o rbenv (https://github.com/rbenv/rbenv#installation)
#    Mais prática: sudo apt-get install ruby
# 2) Baixe o arquivo sigprosld_saldo_orcamento_DATA.TXT.gz
# 3) Descompacte-o
# 4) Copie este script para customização dos filtros
#    cp 03-Controle/scripts/batch/apuracao/saldo_orcamento_to_csv.rb /tmp
# 5) Edite a cópia do script, mais especificamente o método
#    SaldoOrcamentoFilterModule#register_selected?
#    com a sua lógica de análise. O hash @csv_register conterá as
#    informações das colunas importantes.
# 6) Execute o script, passando 2 parâmetros para ele
#    Parâmetro 1, o arquivo de saldo_orcamento descompactado
#    Parâmetro 2, o arquivo CSV de saída
#
#    ./saldo_orcamento_to_csv.rb sigprosql_saldo_orcamento_DATA.TXT saldo_orcamento.out.csv
#
########################################################################

require 'bigdecimal'

SIZE_NUMERICO_16_2 = 18

SIZE_DATA          = 8
SIZE_HORA          = 4
SIZE_DATA_HORA     = SIZE_DATA + SIZE_HORA
SIZE_ORGAO         = 5
SIZE_UG            = 6
SIZE_GESTAO        = 5
SIZE_CELULA_ESFERA = 1
SIZE_CELULA_UO     = 5
SIZE_CELULA_PT     = 17
SIZE_CELULA_FONTE  = 10
SIZE_CELULA_ND     = 8
SIZE_CELULA_UGR    = 6
SIZE_CELULA_PI     = 11
SIZE_CELULA        = SIZE_CELULA_ESFERA + SIZE_CELULA_UO + SIZE_CELULA_PT + SIZE_CELULA_FONTE + SIZE_CELULA_ND + SIZE_CELULA_UGR + SIZE_CELULA_PI
SIZE_CONTA                  = 9
SIZE_CATEGORIA_GASTO        = 1
SIZE_QUANTITATIVOS_INICIAIS = 72
SIZE_QUANTITATIVOS_MENSAIS  = 1440 # 18(caracteres) * 20(repetições) * 4(campos)
SIZE_PTRES                  = 6
SIZE_RESULTADO_LEI          = 1
SIZE_TIPO_CREDITO           = 1

module SaldoOrcamentoFilterModule

  # Modifique este método para obter o filtro desejado
  # Retorne true, caso deseje que o registro seja selecionado para
  # o arquivo de saída
  def register_selected?
    contas_dotacao = ['522110101','522110201','522110209','522120101','522120103','522120201','522120202','522120203','522120301','522120302','522120303','522190101','522190109','522190201','522190209','522190301','522190309','522190400']
    contas_destaque = ['622220100', '522220100']

    registro_de_destaque = contas_destaque.include?(@csv_register[:conta])
    registro_ptres = @csv_register[:ptres] == "089269"

    true if (registro_de_destaque && registro_ptres)
  end
end

module STAFormatterModule
  def format_sta_number_to_br(sta_number)
    if not sta_number.nil?
      i = sta_number[0..15]
      d = sta_number[16..17]
      i + "," + d
    end
  end

  def format_sta_data_hora(sta_data_hora)
    dia = sta_data_hora.slice(0..1)
    mes = sta_data_hora.slice(2..3)
    ano = sta_data_hora.slice(4..7)
    hora = sta_data_hora.slice(8..9)
    min = sta_data_hora.slice(10..11)
    "#{dia}/#{mes}/#{ano} - #{hora}:#{min}"
  end
end

module STAConverterModule
  def sta_number_to_bigdecimal(sta_number)
    if not sta_number.nil?
      i = sta_number[0..15]
      d = sta_number[16..17]
      BigDecimal.new(i + "." + d)
    end
  end
end

class SaldoOrcamentoConverter
  include STAFormatterModule, STAConverterModule, SaldoOrcamentoFilterModule

  attr_accessor :filepath

  def initialize(saldo_orcamento_filepath)
    @filepath = saldo_orcamento_filepath
  end

  def convert_to_csv(output_filepath)
    File.open(output_filepath, 'w') do |output_file|
      write_header output_file

      File.open(@filepath).each do |line|
        process_line output_file, line
      end
    end
  end

protected
  def write_header(file)
    file.write("\"DATA/HORA\";")
    file.write("\"ORGAO\";")
    file.write("\"UG\";")
    file.write("\"GESTAO\";")
    file.write("\"ESFERA\";")
    file.write("\"UO\";")
    file.write("\"PT\";")
    file.write("\"FONTE\";")
    file.write("\"ND\";")
    file.write("\"UGR\";")
    file.write("\"PI\";")
    file.write("\"CONTA\";")
    file.write("\"CATEGORIA_GASTO\";")
    file.write("\"SALDO\";")
    file.write("\"DEBITO_INI\";")
    file.write("\"CREDITO_INI\";")
#    file.write("\"DEBITO_INI_EXT\";")
#    file.write("\"CREDITO_INI_EXT\";")

    ["JAN", "FEV", "MAR", "ABR", "MAI", "JUN", "JUL", "AGO", "SET", "OUT", "NOV", "DEZ"].each do |mes|
      file.write("\"DEBITO_#{mes}\";")
      file.write("\"CREDITO_#{mes}\";")
#      file.write("\"DEBITO_#{mes}_EXT\";")
#      file.write("\"CREDITO_#{mes}_EXT\";")
    end

    file.write("\"PTRES\";")
    file.write("\"RESULTADO LEI\";")
    file.write("\"TIPO CREDITO\"\n")
  end

  def process_line(output_file, line)
    # Descartando colunas não utilizadas no sigpro, baseado no cut do script de carga:
    # cut -c 1-12,14-18,22-32,111-178,183-254,291-1730,2549-2556
    p1 = line.slice(0..11)
    p2 = line.slice(13..17)
    p3 = line.slice(21..31)
    p4 = line.slice(110..177)
    p5 = line.slice(182..253)
    p6 = line.slice(290..1729)
    p7 = line.slice(2548..2555)
    useful_line = p1 + p2 + p3 + p4 + p5 + p6 + p7

    @csv_register = {}
    @csv_register[:data_hora]       = useful_line.slice!(0..SIZE_DATA_HORA - 1)
    @csv_register[:orgao]           = useful_line.slice!(0..SIZE_ORGAO - 1)
    @csv_register[:ug]              = useful_line.slice!(0..SIZE_UG - 1)
    @csv_register[:gestao]          = useful_line.slice!(0..SIZE_GESTAO - 1)
    celula                          = useful_line.slice!(0..SIZE_CELULA - 1)
    @csv_register[:celula]          = celula.dup
    @csv_register[:esfera]          = celula.slice!(0..SIZE_CELULA_ESFERA - 1)
    @csv_register[:uo]              = celula.slice!(0..SIZE_CELULA_UO - 1)
    @csv_register[:pt]              = celula.slice!(0..SIZE_CELULA_PT - 1)
    @csv_register[:fonte]           = celula.slice!(0..SIZE_CELULA_FONTE - 1)
    @csv_register[:nd]              = celula.slice!(0..SIZE_CELULA_ND - 1)
    @csv_register[:ugr]             = celula.slice!(0..SIZE_CELULA_UGR - 1)
    @csv_register[:pi]              = celula.slice!(0..SIZE_CELULA_PI - 1)
    @csv_register[:conta]           = useful_line.slice!(0..SIZE_CONTA - 1)
    @csv_register[:categoria_gasto] = useful_line.slice!(0..SIZE_CATEGORIA_GASTO - 1)
    qtd_ini                         = useful_line.slice!(0..SIZE_QUANTITATIVOS_INICIAIS - 1)
    @csv_register[:debito_ini]      = qtd_ini.slice!(0..SIZE_NUMERICO_16_2 - 1)
    @csv_register[:credito_ini]     = qtd_ini.slice!(0..SIZE_NUMERICO_16_2 - 1)
    @csv_register[:debito_ini_ext]  = qtd_ini.slice!(0..SIZE_NUMERICO_16_2 - 1)
    @csv_register[:credito_ini_ext] = qtd_ini.slice!(0..SIZE_NUMERICO_16_2 - 1)

    # Carregando os valores mensais
    qtd_mensal      = useful_line.slice!(0..SIZE_QUANTITATIVOS_MENSAIS - 1)
    valores_mensais = {
      :debito => [],
      :credito => [],
      :debito_ext => [],
      :credito_ext => []
    }
    saldo = BigDecimal.new("0.0")

    # Carregando o periódico de 20 ocorrências contendo os valores MENSAIS
    # de DEBITO
    20.times do |i|
      valor_atual = qtd_mensal.slice!(0..SIZE_NUMERICO_16_2 - 1)

      if i < 12
        valores_mensais[:debito] << valor_atual
        saldo = saldo.add sta_number_to_bigdecimal(valor_atual), SIZE_NUMERICO_16_2
      end
    end

    # Carregando o periódico de 20 ocorrências contendo os valores MENSAIS
    # de CREDITO
    20.times do |i|
      valor_atual = qtd_mensal.slice!(0..SIZE_NUMERICO_16_2 - 1)

      if i < 12
        valores_mensais[:credito] << valor_atual
        saldo = saldo.sub sta_number_to_bigdecimal(valor_atual), SIZE_NUMERICO_16_2
      end
    end

    # Carregando o periódico de 20 ocorrências contendo os valores MENSAIS
    # de DEBITO_EXT
    20.times do |i|
      valor_atual = qtd_mensal.slice!(0..SIZE_NUMERICO_16_2 - 1)

      if i < 12
        valores_mensais[:debito_ext] << valor_atual
      end
    end

    # Carregando o periódico de 20 ocorrências contendo os valores MENSAIS
    # de CREDITO_EXT
    20.times do |i|
      valor_atual = qtd_mensal.slice!(0..SIZE_NUMERICO_16_2 - 1)

      if i < 12
        valores_mensais[:credito_ext] << valor_atual
      end
    end

    # Se a conta for uma conta par, ou seja, uma conta de crédito (seu primeiro caractere é 2, 4, 6 ou 8),
    # seu saldo encontra-se invertido (pois adotamos a convensão DEBITO - CRÉDITO).
    # Dessa forma,
    if (@csv_register[:conta][0].to_i % 2) == 0
      saldo = saldo.mult BigDecimal.new("-1"), SIZE_NUMERICO_16_2
    end

    @csv_register[:valores_mensais] = valores_mensais
    @csv_register[:saldo]           = saldo

    @csv_register[:ptres]           = useful_line.slice!(0..SIZE_PTRES - 1)
    @csv_register[:resultado_lei]   = useful_line.slice!(0..SIZE_RESULTADO_LEI - 1)
    @csv_register[:tipo_credito]    = useful_line.slice!(0..SIZE_TIPO_CREDITO - 1)

    # Aplica o filtro no registro
    if register_selected?
      write_csv_register(output_file)
    end
  end

  def write_csv_register(output_file)
    output_file.write('"' "#{format_sta_data_hora(@csv_register[:data_hora])}" '";')
    output_file.write('"' "#{@csv_register[:orgao]}"                           '";')
    output_file.write('"' "#{@csv_register[:ug]}"                              '";')
    output_file.write('"' "#{@csv_register[:gestao]}"                          '";')
    output_file.write('"' "#{@csv_register[:esfera]}"                          '";')
    output_file.write('"' "#{@csv_register[:uo]}"                              '";')
    output_file.write('"' "#{@csv_register[:pt]}"                              '";')
    output_file.write('"' "#{@csv_register[:fonte]}"                           '";')
    output_file.write('"' "#{@csv_register[:nd]}"                              '";')
    output_file.write('"' "#{@csv_register[:ugr]}"                             '";')
    output_file.write('"' "#{@csv_register[:pi]}"                              '";')
    output_file.write('"' "#{@csv_register[:conta]}"                           '";')
    output_file.write('"' "#{@csv_register[:categoria_gasto]}"                 '";')
    output_file.write("#{@csv_register[:saldo].to_s('F').tr(".", ",")};")
    output_file.write("#{format_sta_number_to_br(@csv_register[:debito_ini])};")
    output_file.write("#{format_sta_number_to_br(@csv_register[:credito_ini])};")
#    output_file.write("#{format_sta_number_to_br(@csv_register[:debito_ini_ext])};")
#    output_file.write("#{format_sta_number_to_br(@csv_register[:credito_ini_ext])};")

    12.times do |mes|
      debito_mes = @csv_register[:valores_mensais][:debito][mes]
      credito_mes = @csv_register[:valores_mensais][:credito][mes]
#      debito_mes_ext = @csv_register[:valores_mensais][:debito_ext][mes]
#      credito_mes_ext = @csv_register[:valores_mensais][:credito_ext][mes]

      output_file.write("#{format_sta_number_to_br(debito_mes)};")
      output_file.write("#{format_sta_number_to_br(credito_mes)};")
#      output_file.write("#{format_sta_number_to_br(debito_mes_ext)};")
#      output_file.write("#{format_sta_number_to_br(credito_mes_ext)};")
    end

    output_file.write('"' "#{@csv_register[:ptres]}"           '";')
    output_file.write('"' "#{@csv_register[:resultado_lei]}"   '";')
    output_file.write('"' "#{@csv_register[:tipo_credito]}"  "\"\n")
  end
end

def print_usage
  puts "Usage"
  puts "\t./apurar-saldo-orcamento.rb SALDO_ORCAMENTO_FILEPATH CSV_OUTPUT_FILEPATH"
  puts
end

def parse_arguments
  if ARGV.size != 2
    print_usage
    raise ArgumentError, "Wrong number of parameters"
  end
end

def main
  parse_arguments

  converter = SaldoOrcamentoConverter.new ARGV[0]
  converter.convert_to_csv ARGV[1]
end

main
