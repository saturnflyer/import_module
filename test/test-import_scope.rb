#!/usr/bin/env ruby
["..", "../lib", "../dev-lib"].each do |x| $LOAD_PATH.unshift x; end
require "scope-in-state-18"
require "import-module"

class Foo
  def foo; "Foo"; end
end

module Mod1
  module Foo
    def foo; "Mod1"; end
  end
end

s = ScopeInState.new(Mod1)

foo = Foo.new
p foo.foo

module Mod2
  def foo; "Mod2"; end
end

Foo.import_module(Mod2) do
  p foo.foo
  s.scope_in do
    p foo.foo
  end
  p foo.foo
end

p foo.foo
