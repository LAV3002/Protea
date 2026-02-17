require 'Common/scope'

module Devices
  @@desc = {
    devices: []
  }

  @@semablocks = []

  def self.getSemablocks
    @@semablocks
  end

  def self.initScope
    scope = Protea::Scope.new(nil)
    @@desc[:devices][0][:registers].each do |reg|
      regvar = scope.method(reg[:name], :regref)

      reg[:fields].each do |field|
        regvar.define_singleton_method(field[:name]) do
          @scope.get_field(self, field[:lsb], ('b' + field[:size].to_s).to_sym)
        end
      end
    end
    
    return scope
  end

  def self.processSemablocks
    @@semablocks.each do |block|
      scope = initScope
      scope.instance_eval(&block[2])
      block[0][block[1]] = scope.to_h
    end

    @@semablocks = []
  end

  def self.getDesc
    @@desc
  end

  class RegBuilder
    attr_accessor :info

    def initialize(name)
      @info = { name: name, fields: [] }
    end

    def size(value)
      @info[:size] = value
    end

    def offset(value)
      @info[:offset] = value
    end

    def type(value)
      @info[:type] = value
    end

    def enableIf(&block)
      Devices.getSemablocks << [@info, :enableIf, block]
    end

    def field(name, lsb, size = 1)
      @info[:fields] << { name: name, lsb: lsb, size: size }
    end
  end

  class DeviceBuilder
    attr_accessor :info

    def initialize(name)
      @info = { name: name, registers: [] }
    end

    def Register(name, &block)
      regBuilder = RegBuilder.new(name)
      regBuilder.instance_eval(&block)
      @info[:registers] << regBuilder.info
      nil
    end
  end

  def self.Device(name, &block)
    deviceBuilder = DeviceBuilder.new(name)
    deviceBuilder.instance_eval(&block)
    @@desc[:devices] << deviceBuilder.info
    Devices.processSemablocks
    nil
  end
end
