#!/usr/bin/ruby
# frozen_string_literal: true

require 'Common/base'
require 'ADL/builder'
require 'Target/RISC-V/32I'

require 'yaml'

Protea.serialize

yaml_data = YAML.safe_load(
  Protea.state,
  permitted_classes: [Symbol],
  symbolize_names: true
)

yaml_data[:isa_name] = "RISCV"
Dir.mkdir('sim_lib/generated/') unless File.exist?('sim_lib/generated/')
File.write('sim_lib/generated/IR.yaml', yaml_data.to_yaml)
