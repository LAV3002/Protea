#!/usr/bin/ruby
# frozen_string_literal: true
require 'yaml'

require 'Devices/ns16550'

puts Devices.getDesc.to_yaml
