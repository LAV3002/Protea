#!/usr/bin/ruby
# frozen_string_literal: true
require 'yaml'

require 'Devices/clint'
# require 'Devices/ns16550'

System.process_semablocks

puts System.desc.to_yaml
