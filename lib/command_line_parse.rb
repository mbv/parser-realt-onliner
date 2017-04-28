require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'
require_relative 'opener'
require_relative 'abstract_saver'



class CommandLineParse
  RENT_TYPES = %w[room 1_room 2_rooms 3_rooms 4_rooms 5_rooms 6_rooms].freeze
  FORMATS = %w[csv json].freeze
  METRO = %w[blue_line red_line].freeze

  class ScriptOptions
    attr_accessor :min_price, :max_price, :rent_types, :currency,
                  :metro, :only_owner, :format

    def initialize
      self.currency = 'usd'
      self.format = 'csv'
    end

    def define_options(parser)
      parser.banner = 'Usage: solution.rb [options]'
      parser.separator ''
      parser.separator 'Specific options:'

      min_price_option(parser)
      max_price_option(parser)
      currency_option(parser)
      rent_types_option(parser)
      owner_option(parser)
      format_option(parser)

      parser.separator ''
      parser.separator 'Common options:'
      parser.on_tail('-h', '--help', 'Show this message') do
        puts parser
        exit
      end
    end

    def min_price_option(parser)
      parser.on('--min_price 100', Integer, 'Enter min price') do |min_price|
        self.min_price = min_price
      end
    end

    def max_price_option(parser)
      parser.on('--max_price 100', Integer, 'Enter max price') do |max_price|
        self.max_price = max_price
      end
    end

    def currency_option(parser)
      parser.on('-c USD', '--currency USD', String, 'Enter currency') do |currency|
        self.currency = currency
      end
    end

    def rent_types_option(parser)
      parser.on('--rent_type room,1_room', Array,
                'Enter number of rooms') do |rent_types|
        raise OptionParser::InvalidArgument, 'Invalid rent type' unless (rent_types - RENT_TYPES).empty?
        self.rent_types = rent_types
      end
    end

    def metro_option(parser)
      parser.on('-m blue_line,red_line', '--metro blue_line,red_line', Array,
                'Enter number of rooms') do |metro|
        raise OptionParser::InvalidArgument, 'Invalid metro type' unless (metro - METRO).empty?
        self.metro = metro
      end
    end

    def owner_option(parser)
      parser.on('-o', '--[no-]owner', 'Only owner') do |only_owner|
        self.only_owner = only_owner
      end
    end

    def format_option(parser)
      parser.on('-f csv', '--format csv', FORMATS,
                'Enter output format (csv, json)') do |format|
        self.format = format
      end
    end
  end

  def parse(args)
    @options = ScriptOptions.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
    end
    @options
  end

  attr_reader :options
end

example = CommandLineParse.new
options = example.parse(ARGV)
pp options

result = Opener.new(options).start
CsvSaver.new('file.csv').save result
JsonSaver.new('file.json').save result
