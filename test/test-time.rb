#!/usr/local/bin/ruby
import_module = "import-module"
#$IMPORT_MODULE_debug = true
n = 10000
$SL = $LS = true
scope_in_state = nil

ARGV.delete_if do |x|
  case x
  when "m"
    import_module = "import-module"
    true
  when "p"
    import_module = "import-module-pip"
    true
  when "q"
    import_module = "import-module-pip-b"
    true
  when "u"
    import_module = "import-module-unbound-method"
    true
  when "h"
    import_module = "import-module-hash"
    true
  when "s"
    import_module = "import-module-single-thread"
    true
  when "c"
    scope_in_state = "scope-in-state"
    true
  when "b"
    scope_in_state = "scope-in-state-b"
    true
  when "a"
    scope_in_state = "scope-in-state-ab"
    true
  when /\.rb$/
    import_module = x
    true
  when /^[0-9]+$/
    n = Integer(x)
  when "L"
    $SL = false
    $LS = true
    true
  when "S"
    $SL = true
    $LS = false
    true
  else
    false
  end
end

unless ARGV.empty?
  puts "Usage: n times loop
  ruby #$0 m n : import_module
  ruby #$0 p n: import_module-pip
  ruby #$0 q n: import_module-pip-b
  ruby #$0 u n: import_module-unbound-method
  ruby #$0 s n: import_module-single-thread
  ruby #$0 c n: scope-in-state
  ruby #$0 b n: scope-in-state-b
  ruby #$0 a n: scope-in-state-ab
"
end

def bm(s = "", t = nil)
  if t
    s += " " + t
  end
  start = Time.now
  v = yield
  [s, Time.now - start]
end

r = []
a, b = "(scopes in #{n} loops)", "(#{n} loops in a scope)"

class Foo
  def foo
    0
  end
end
class Foo0
  def foo
    0
  end
end
class Foo1
  def foo
    0
  end
end
class Foo2
  def foo
    0
  end
end

module Bar
  def foo
    1
  end
end

module Bar0
  def foo
    1
  end
end
module S1
  module Foo1
    def foo
      1
    end
  end
end
module S2
  module Foo2
    def foo
      1
    end
  end
end


unless scope_in_state
    require import_module
#    m = "multi thread"
  m = import_module.sub(/\.\//, "")#/

  o = Foo.new
  o0 = Foo0.new

  if $SL
    r << bm(m, a) do
      n.times do
	Foo.import_module(Bar) do
	  o.foo
	end
      end
    end
  end
  if $LS
    Foo0.import_module(Bar0) do
      r << bm(m, b) do
	n.times do
	  o0.foo
	end
      end
    end
  end
else
  m = scope_in_state.sub(/\.\//, "")#/
  require scope_in_state
  o1 = Foo1.new
  o2 = Foo2.new
  ScopeS1 = ScopeInState.new(S1)
  ScopeS2 = ScopeInState.new(S2)
  if $SL
    r << bm(m, a) do
      n.times do
	ScopeS1.scope_in do
	  o1.foo
	end
      end
    end
  end
  if $LS
    ScopeS2.scope_in do
      r << bm(m, b) do
	n.times do
	  o2.foo
	end
      end
    end
  end
end


r.each do |m, f|
  printf "%-54s: %3.4f\n", m, f
end
