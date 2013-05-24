#!/usr/local/bin/ruby
require "import-module"

module Import_Module
  class BaseClass;end

  class Scope
    attr_reader :updator

    def initialize(target, source)
      @target = target
      @klass = target.klass
      @source = source
      @mod = source.mod
      @updator = forward_code(@source.methods, @mod)   ###
    end

    def set_methods
      meths = @target.get_orig_methods(@source)
      @target.def_orig_methods(meths, true)
      #def_base_methods(meths)
      BaseClass.class_eval *forward_code(meths, :orig) ###
      def_methods
      mod = @mod
      @klass.class_eval do include mod end
    end

    #private

    def update(c)
      d = Class.new(c.class)
      d.class_eval *@updator
      d.new
    end

    def method_code(meth) #entity
      meth0 = Import_Module.name(meth, @klass, false)
      param = @source.param(meth)
      param0 = @source.param0(meth)
      line_no = __LINE__ + 1
      s =  "def #{meth}(#{param})\n"
      s << "  Thread.current.__IMPORT_MODULE_PREFIX_proxy.#{meth0}(self, #{param0})\n"
      s << "end\n"
      s << "protected(:#{meth})\n" if @target.protecteds.include?(meth)
      s << "private(:#{meth})\n" if @target.privates.include?(meth)
      [s, __FILE__, line_no]
    end

    def forward_code(meths, mod)
      s = ""
      line_no = __LINE__ + 6
      meths.__each__ do |meth|
	meth0 = Import_Module.name(meth, @klass, false)
	meth1 = Import_Module.name(meth, mod)
	param = @source.param(meth)
	param0 = @source.param0(meth)
	s << "def #{meth0}(sender, #{param0})\n"
	s << "  sender.#{meth1}(#{param})\n"
	s << "end\n"
      end
      [s, __FILE__, line_no]
    end

    def def_base_methods(meths)#do not use (but faster)
      BaseClass.class_eval *forward_code(meths, :orig)
    end
  end
end

Thread.current.__IMPORT_MODULE_PREFIX_stack =
  Import_Module::Stack.new([Import_Module::BaseClass.new])
