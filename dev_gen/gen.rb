#!/usr/bin/ruby
# frozen_string_literal: true

require 'yaml'
require_relative 'gen_hpp'
require_relative 'timer'

ir = YAML.load_file(ARGV[0])

ir[:devices].each do |name, desc|
  puts DevGen.gen_header(name, desc, DevGen::Timer)
end
