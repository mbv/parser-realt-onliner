require_relative 'opener'
require_relative 'abstract_saver'
require_relative 'command_line_parse'
require_relative 'param_formatter'

class Solution

  MAP_FORMATS = { 'json' => JsonSaver,
                  'csv'  => CsvSaver }.freeze

  def start
    command_line_parser = CommandLineParse.new
    raw_params          = command_line_parser.parse(ARGV)

    params_formatter = ParamFormatter.new(raw_params)

    result = Opener.new(params_formatter.params).start
    if result.right?
      MAP_FORMATS[params_formatter.format].new(params_formatter.path).save result.value[:apartments]
    else
      puts result.value
    end
  end

end

Solution.new.start
