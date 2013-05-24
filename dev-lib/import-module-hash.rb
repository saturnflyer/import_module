#!/usr/local/bin/ruby
#  Old Hash Version
#$IMPORT_MODULE_debug = true

require "import-module"

module Import_Module
  class Scope
    def set_methods
      meths = @target.get_orig_methods(@source)
      @target.def_orig_methods(meths)
      def_methods
      mod = @mod
      @klass.class_eval do include mod end
    end

    def update(c)
      d = c.dup
      @source.methods.__each__ do |meth|
	d[Import_Module.name(meth, @klass, false).intern.object_id] = @mod.object_id
      end
      d
    end

    def method_code(meth)
      param = @source.param(meth)
      methid = Import_Module.name(meth, @klass, false).intern.object_id
      line_no = __LINE__ + 1
      s = "def #{meth}(#{param})"
      s << "  modid = Thread.current.__IMPORT_MODULE_PREFIX_proxy[#{methid}]\n"
      i = 0
     @target.scopes.each_key do |mod|
	s << (i == 0 ? "  " : "  els") << "if modid == #{mod.object_id}\n"
	s << "    #{Import_Module.name(meth, mod)}(#{param})\n"
	i += 1
      end
      s << "  else\n" if i > 0
      s << "    #{Import_Module.name(meth, :orig)}(#{param})\n"
      s << "  end\n" if i > 0
      s << "end\n"
      s << "protected(:#{meth})\n" if @target.protecteds.include?(meth)
      s << "private(:#{meth})\n" if @target.privates.include?(meth)
      [s, __FILE__, line_no]
    end
  end
end

Thread.current.__IMPORT_MODULE_PREFIX_stack =
  Import_Module::Stack.new([Hash.new])
