#!/usr/local/bin/ruby
# compatible with 0.71beta1

require "import-module"
module Import_Module
  class Scope
    private
    def method_code(meth)
      param = @source.param(meth)
      no = @target.meth_no[meth]
      v = Import_Module.name(meth, @klass, false)
      line_no = __LINE__ + 1
      s = "def #{meth}(#{param})\n"
      s << "  if m = Thread.current.__IMPORT_MODULE_PREFIX_proxy[#{no}]\n"
      s << "    m.bind(self).call(#{param})\n"
      s << "  else\n"
      s << "    #{Import_Module.name(meth, :orig)}(#{param})\n"
      s << "  end\n"
      s << "end\n"
      s << "protected(:#{meth})\n" if @target.protecteds.include?(meth)
      s << "private(:#{meth})\n" if @target.privates.include?(meth)
      [s, __FILE__, line_no]
    end
  end

  class Scope
    private
    def update(c)
      d = c.dup
      @source.methods.__each__ do |meth|
	d[@target.meth_no[meth]] = @mod.instance_method(meth)
      end
      d
    end
  end
end
