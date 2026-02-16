require_relative '../Common/scope'

module Devices

  # class Oper
  #   attr_accessor :kind, :ret, :opds

  #   def initialize(kind, ret, *opds)
  #     @kind = kind
  #     @ret = ret
  #     @opds = opds
  #   end
  # end

  # class ConstExpr
  #   attr_accessor :type, :kind, :value

  #   def initialize(type, value)
  #     @type = type
  #     @kind = :const
  #     @value = value
  #   end
  # end

  # class VarExpr
  #   attr_accessor :type, :kind, :name

  #   def initialize(type, name)
  #     @type = type
  #     @kind = :var
  #     @value = name
  #   end
  # end

  # class ExprWrapper
  #   attr_accessor :expr

  #   class << self
  #     attr_accessor :currentScope
  #   end

  #   @@tmpCounter = 0
  #   @@currentScope = nil

  #   def initialize(expr)
  #     @expr = expr
  #   end

  #   def self.setScope(scope)
  #     @@currentScope = scope
  #   end

  #   def self.nthOp(n, kind, retType, *args)
  #     var = VarExpr(retType, "tmp_#{@@tmpCounter}".to_sym)
  #     @@tmpCounter += 1

  #     @@currentScope < Oper(kind, var, *(args.map { |arg| arg.expr }))

  #     return ExprWrapper.new(var)
  #   end

  #   def self.binOp(lhs, rhs, kind, retType = nil)
  #     if lhs.type != rhs.type
  #       raise "Bad bin op args"
  #     end

  #     if retType.nil?
  #       retType = lhs.type
  #     end

  #     return nthOp(2, kind, retType, lhs, rhs)
  #   end

  #   def+(other); binOp(self, other, :add); end
  #   def-(other); binOp(self, other, :sub); end
  #   def<<(other); binOp(self, other, :shl); end
  #   def<(other); binOp(self, other, :lt, bv(1)); end
  #   def>(other); binOp(self, other, :gt, bv(1)); end
  #   def^(other); binOp(self, other, :xor); end
  #   def>>(other); binOp(self, other, :shr); end
  #   def|(other); binOp(self, other, :or) end
  #   def&(other); binOp(self, other, :and) end
  #   def==(other); binOp(self, other, :eq, bv(1)); end
  #   def!=(other); binOp(self, other, :ne, bv(1)); end
  #   # def[](r, l); @scope.extract(self, r, l); end

  # end

  # class Statement < Utils::BaseInfo(:retVar, :op, :args)
  #   def initialize()
  #     super(nil, nil, [])
  #   end
  # end

  # class CallHandler
  #   attr_accessor :symbolName, :args, :next

  #   def initialize(name, *args)
  #     @symbolName = name
  #     @args = args
  #     @next = nil

  #     stmt = Statement.new()
  #     obj = getTmp()
  #     stmt.retVar = obj
  #     stmt.op = :getObj
  #     stmt.args = [callHandler.symbolName.to_sym]
  #     @@scopeInstance << stmt

  #     if !callHandler.args.empty?
  #       callStmt = Statement.new()
  #       stmt.retVar = getTmp()
  #       stmt.op = :call
  #       stmt.args = [obj] + callHandler.args
  #       @@scopeInstance << callStmt
  #     end

  #     puts @symbolName
  #     puts @args
  #   end

  #   def method_missing(name, *args)
  #     @next = CallHandler.new(name, *args)

  #     return @next
  #   end
  # end

  # module Scope
  #   def self.method_missing(name, *args)
  #     return ExprWrapper.new(name, *args)
  #   end
  # end

  @@desc = {
    devices: []
  }

  @@semablocks = []

  def self.getSemablocks
    @@semablocks
  end

  def self.initScope
    scope = LangInfra::Scope.new(nil)
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
      # puts block[0]
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
