#!/usr/local/bin/ruby
#$IMPORT_MODULE_debug = true
#$d2 = true
#$SUPER = true
#$debug = true
#$PIP = true

Thread.abort_on_exception = true
$single_thread = false
$script_dir = ""#"../"
["..", "../lib", "../dev-lib"].each do |x|
  $LOAD_PATH.unshift x
end
$import_module = $script_dir + "import-module"

ARGV.delete_if do |x|
  case x
  when "m"
    $import_module = $script_dir + "import-module"
    true
  when "p"
    $import_module = $script_dir + "import-module-pip"
    true
  when "q"
    $import_module = $script_dir + "import-module-pip-b"
    true
  when "h"
    $import_module = $script_dir + "import-module-hash"
    true
  when "u"
    $import_module = $script_dir + "import-module-unbound-method"
    $stderr.puts "Warning: 'import' is not tested for unbound-method"
    $UNBOUND = true
    true
  when "s"
    $import_module = $script_dir + "import-module-single-thread"
    $single_thread_mode = true
    true
  when /^:/
    $spot = x.sub(/^:/, '')
    true
  when /\.rb$/
    $import_module = x
    true
  else
    false
  end
end

require $import_module
#puts Import_Module::IMPORT_MODULE_Version

$N = 0
def assert(m, n = nil)
  return if $spot && self.to_s != $spot
  $N += 1
  unless n.nil?
    if m == n
      puts "#$N (#{self}): OK"
    else
      puts "NG (#{self}): #{m.inspect} != #{n.inspect}"
      puts caller#.first
      exit!(255)
    end
  else
    if m
      puts "#$N (#{self}): OK"
    else
      puts "NG (#{self}): #{m.inspect}"
      puts caller#.first
      exit!(255)
    end
  end
end

puts "SINGLE THREAD TEST"

module First
  class A
    def m; 0; end
  end
  module M
    def m; 1; end
  end
  a = A.new
  assert(a.m, 0)
  A.import_module(M) do
    assert(a.m, 1)
  end
  assert(a.m, 0)
end

module Second
  module M001
    def m; 1; end
  end
  module M002
    def m; 2; end
  end
  class A000
    def m; 0; end
  end
  a = A000.new
  A000.import_module(M001) do
    A000.import_module(M002) do
      assert(a.m, 2)
    end
    assert(a.m, 1)
  end
  assert(a.m, 0)
end
  
# non existance
module NonExistance
  module M021
    def m; 1; end
  end
  module M022
    def m; 2; end
  end
  class A020
  end
  a = A020.new
  A020.import_module(M021) do
    A020.import_module(M022) do
      assert(a.m, 2)
    end
    assert(a.m, 1)
  end
  begin
    assert(a.m, 0)
  rescue NameError
  else
    raise
  end
end

# Elementary
module Elementary
  module MMm0
    def m; 0; end
  end
  module MMm1
    def m; 1; end
  end
  module MMm2
    def m; 2; end
  end
  class Am3
    def m; 3; end
  end
  class Bm4
    def m; 4; end
  end
  module MMm5
    def m; 5; end
  end
  module MMm6
    def m; 6; end
    def n; 7; end
  end
  module MMmi6
    include MMm6
  end
  a = Am3.new
  b = Bm4.new
  assert(a.m, 3)
  assert(b.m, 4)
  Am3.import_module(MMm0) do
    assert(a.m, 0)
    assert(b.m, 4)
    Bm4.import_module(MMm2) do
      assert(a.m, 0)
      assert(b.m, 2)
      Bm4.import_module(MMmi6) do
	assert(a.m, 0)
	assert(b.m, 6)
	#      assert(b.n, 7)
      end
      assert(a.m, 0)
      assert(b.m, 2)
      Am3.import_module(MMm5) do
	assert(a.m, 5)
	assert(b.m, 2)
      end
      assert(a.m, 0)
      assert(b.m, 2)
    end
    assert(a.m, 0)
    assert(b.m, 4)
  end
  assert(a.m, 3)
  assert(b.m, 4)
end

module StarArg
  class Am3
    def m; 3; end
  end
  module MMm7
    def f(x); x; end
    def g(x, *a); [x]+a; end
  end
  module MMm8
    def f(x); x+1; end
    def g(x, *a); [x+1]+a; end
  end
  a = Am3.new
  Am3.import_module(MMm7) do
    assert(a.f(0), 0)
    assert(a.g(0, 0), [0, 0])
    Am3.import_module(MMm8) do
      assert(a.f(0), 1)
      assert(a.g(0, 1), [1, 1])
    end
    assert(a.f(0), 0)
    assert(a.g(0, 0), [0, 0])
  end
end  

##### inheritance
module Inheritance
  class Foo21
    def foo; 21; end
  end
  class Bar21
    def bar; 21; end
  end
  module S22
    def foo; 22; end
    def bar; 22; end
  end
  class Foo23 < Foo21
  end
  class Bar23 < Bar21
    def bar; 23; end
  end
  
  o = Foo23.new
  u = Bar23.new
  Foo21.import_module(S22) do
    assert(o.foo, 22)
  end
  #Foo21.import_module(S22) do
  Bar21.import_module(S22) do
    assert(u.bar, 23)
  end
end

# Private, New Method
module Private_NewMethod
  class C0m_n
    def m; 0; end
    def n; 0; end
    def assert_n(x)
      assert(n, x)
    end
    private :n
  end
  module M1mnq
    def m; 1; end
    def n; 1; end
    def q; 1; end
    private :n
  end
  o = C0m_n.new
  assert(o.m, 0)
  o.assert_n(0)
  C0m_n.import_module(M1mnq) do
    assert(o.m, 1)
    o.assert_n(1)
    assert(o.q, 1)
  end
  assert(o.m, 0)
  o.assert_n(0)
  begin
    o.n
  rescue NameError
  else
    raise "ERROR: can call private method"
  end
end

module Private_Protected
  class Foo
    def public_foo; end
    def private_foo; end
    def protected_foo; end
    private :private_foo
    protected :protected_foo
  end
  
  module Bar
    def public_foo; end
    def private_foo; end
    def protected_foo; end
  end
  
  Foo.import_module(Bar) do
    assert(Foo.public_instance_methods(true).include?("public_foo"), true)
    assert(Foo.private_instance_methods(true).include?("private_foo"), true)
    assert(Foo.protected_instance_methods(true).include?("protected_foo"), true)
  end
  assert(Foo.public_instance_methods(true).include?("public_foo"), true)
  assert(Foo.private_instance_methods(true).include?("private_foo"), true)
  assert(Foo.protected_instance_methods(true).include?("protected_foo"), true)
end

module Private_Proteced_Inheritance
  class Foo
    def public_foo; end
    def private_foo; end
    def protected_foo; end
    private :public_foo
    protected :private_foo
  end
  
  module Bar
    def public_foo; end
    def private_foo; end
    def protected_foo; end
  end

  class Baz < Foo
    def public_foo; end
    def private_foo; end
    def protected_foo; end
    private :private_foo
    protected :protected_foo
  end
  
  if RUBY_VERSION >= "1.7.0"
  Baz.import_module(Bar) do
    assert(Baz.public_instance_methods(true).include?("public_foo"), true)
    assert(Baz.private_instance_methods(true).include?("public_foo"), false)
    assert(Baz.protected_instance_methods(true).include?("public_foo"), false)
    assert(Baz.public_instance_methods(true).include?("private_foo"), false)
    assert(Baz.private_instance_methods(true).include?("private_foo"), true)
    assert(Baz.protected_instance_methods(true).include?("private_foo"), false)
    assert(Baz.public_instance_methods(true).include?("protected_foo"), false)
    assert(Baz.public_instance_methods(true).include?("protected_foo"), false)
    assert(Baz.protected_instance_methods(true).include?("protected_foo"), true)
  end
  assert(Baz.public_instance_methods(true).include?("public_foo"), true)
  assert(Baz.private_instance_methods(true).include?("private_foo"), true)
  assert(Baz.protected_instance_methods(true).include?("protected_foo"), true)
  end
end

module Private_Proteced_Inheritance
  class Foo
    def public_foo; end
    def private_foo; end
    def protected_foo; end
    private :private_foo
    protected :protected_foo
  end
  
  module Bar
    def public_foo; end
    def private_foo; end
    def protected_foo; end
    private :public_foo
    protected :private_foo
  end

  class Baz < Foo
  end
  
  if RUBY_VERSION >= "1.7.0"
  Baz.import_module(Bar) do
    assert(Baz.public_instance_methods(true).include?("public_foo"), true)
    assert(Baz.private_instance_methods(true).include?("public_foo"), false)
    assert(Baz.protected_instance_methods(true).include?("public_foo"), false)
    assert(Baz.public_instance_methods(true).include?("private_foo"), false)
    assert(Baz.private_instance_methods(true).include?("private_foo"), true)
    assert(Baz.protected_instance_methods(true).include?("private_foo"), false)
    assert(Baz.public_instance_methods(true).include?("protected_foo"), false)
    assert(Baz.public_instance_methods(true).include?("protected_foo"), false)
    assert(Baz.protected_instance_methods(true).include?("protected_foo"), true)
  end
  assert(Baz.public_instance_methods(true).include?("public_foo"), true)
  assert(Baz.private_instance_methods(true).include?("private_foo"), true)
  assert(Baz.protected_instance_methods(true).include?("protected_foo"), true)
  end
end

#unless single_thread_mode?
##  assert(C0m_n.instance_methods.size, 5)
##  assert(C0m_n.private_instance_methods.size, 1)
  #p C0m_n.instance_methods
  #p C0m_n.private_instance_methods
#else
##  assert(C0m_n.instance_methods.size, 2+1)
##  assert(C0m_n.private_instance_methods.size, 1+1)
#end

### triple
module Triple
  class F0
    def f; 0; end
    def g; 0; end
    def h; 0; end
  end
  module F1
    def f; 1; end
    def g; 1; end
  end
  module F2
    def g; 2; end
    def h; 2; end
  end
  o = F0.new
  F0.import_module(F1) do
    assert([o.f, o.g, o.h], [1, 1, 0])
    F0.import_module(F2) do
      assert([o.f, o.g, o.h], [1, 2, 2])
    end
    assert([o.f, o.g, o.h], [1, 1, 0])
  end
  assert([o.f, o.g, o.h], [0, 0, 0])
end

# Deep Nesting 1
module DeepNesting1
  module M031
    def m; 1; end
  end
  module M032
    def m; 2; end
  end
  class C030
    def m; 0; end
  end
  o = C030.new
  C030.import_module(M031) do
    C030.import_module(M032) do
    end
  end
  assert(o.m, 0)
  C030.import_module(M031) do
    assert(o.m, 1)
  end
end

# Deep Nesting 2
module DeepNesting2
  module M0mn
    def m; 0; end
    def n; 0; end
  end
  module M1mn
    def m; 1; end
    def n; 1; end
  end
  module M2mn
    def m; 2; end
    def n; 2; end
  end
  module M3mn
    def m; 3; end
    def n; 3; end
  end
  class DM0mn
    include M0mn
  end
  o = DM0mn.new
  DM0mn.import_module(M1mn) do
    DM0mn.import_module(M2mn) do
      assert(o.m, 2)
      assert(o.n, 2)
    end
    assert(o.m, 1)
    assert(o.n, 1)
  end
  assert(o.m, 0)
  assert(o.n, 0)

  DM0mn.import_module(M1mn) do
    assert(o.m, 1)
    assert(o.n, 1)
    DM0mn.import_module(M2mn) do
      assert(o.m, 2)
      assert(o.n, 2)
      DM0mn.import_module(M0mn) do
	assert(o.m, 0)
	assert(o.n, 0)
      end
      assert(o.m, 2)
      assert(o.n, 2)
      DM0mn.import_module(M3mn) do
	assert(o.m, 3)
	assert(o.n, 3)
      end
      assert(o.m, 2)
      assert(o.n, 2)
    end
    assert(o.m, 1)
    assert(o.n, 1)
    DM0mn.import_module(M3mn) do
      assert(o.m, 3)
      assert(o.n, 3)
    end
    assert(o.m, 1)
    assert(o.n, 1)
  end
  assert(o.m, 0)
  assert(o.n, 0)
  #assert(DM0mn.instance_methods.sort, ["m", "n"])
end

# Singleton Method
module SingletonMethod
  class Foo
    def m; 0; end
  end
  module Bar
    def m; 1; end
  end
  o0 = Foo.new
  o1 = Foo.new
  o0.import(Bar) do
    assert(o0.m, 1) unless $UNBOUND
    assert(o1.m, 0) unless $UNBOUND
  end
end

module SingletonMethod2
  module Mm0
    def self.m; 0; end
  end
  module Mm4
    def m; 4; end
  end
  assert(Mm0.m, 0)
  Mm0.import(Mm4) do
    assert(Mm0.m, 4) unless $UNBOUND
  end
  assert(Mm0.m, 0)
end

##### SUPER
module Super
  module MB0
    set_orig_method :_f, :f
    def f;[_f, 0]; end
  end
  module MB1
    include MB0
    def f;[super, 1]; end
  end
  module MB2
    include MB1
    def f; [super, 2]; end
  end
  
  class BB
    def f; 0; end
  end
  class FB < BB
    include MB2
    def f; -1; end
  end
  o = FB.new

  FB.import_module(MB2) do
    assert(o.f, [[[-1, 0], 1], 2])
  end
end


module Super2
  module Each_Index
    set_orig_method :_each, :each
    def each(&b)
      i = 0
      _each do |x|
	yield(x, 2 * i)
	i += 1
      end
    end
  end

# mapmap 
#  assert([10, 11, 12].import(Each_Index) {|s| s.map{|x| x}},
#	 [[10, 0], [11, 2], [12, 4]]) unless $UNBOUND
  assert([10, 11, 12].map{|x| x}, [10, 11, 12]) unless $UNBOUND
  
  module Each_Char
    def each(&b); split(//).each(&b); end
  end
  assert("abc".import(Each_Char){|s| s.map{|x| x.succ}}.join(""),
	 "bcd") unless $UNBOUND
  assert("abc".import(Each_Char){|s| s.map{|x| x.succ}}.join(""),
	 "bcd") unless $UNBOUND
end

module Super3
  class FE
    include Enumerable
    def each
      yield 10
      yield 20
      yield 30
    end
  end
  module IndexedEach
    set_orig_method :_each, :each
    def each
      i = 0
      _each do |x|
	i += 1
	yield(i, x)
      end
    end
  end
#  module IndexedEach2
#    def each
#      i = 0
#      super do |x|
#	i += 1
#	yield(2*i, x)
#      end
#    end
#  end
  foo = FE.new
  FE.import_module(IndexedEach) do
    assert(foo.to_a, [[1, 10], [2, 20], [3, 30]])
#    FE.import_module(IndexedEach2) do
#      assert(foo.to_a, [[2, [1, 10]], [4, [2, 20]], [6, [3, 30]]])
#    end
#    assert(foo.to_a, [[1, 10], [2, 20], [3, 30]])
  end
end

### Scope_module
module ScopeCreate
  class A
    def foo
      0
    end
  end
  module M
    def foo
      1
    end
  end
  module N
    def foo
      2
    end
  end
  
  class SC0
    def foo; 0; end
  end
  module SM1
    def foo; 1; end
  end
  module SM2
    def foo; 2; end
  end
  s1 = Import_Module::Scope.create(SC0, SM1)
  s2 = Import_Module::Scope.create(SC0, SM2)
  c = SC0.new
  assert(c.foo, 0)
  s1.activate do
    assert(c.foo, 1)
    s2.activate do
      assert(c.foo, 2)
      s1.activate do
	assert(c.foo, 1)
      end
      assert(c.foo, 2)
    end
    assert(c.foo, 1)
  end  
  assert(c.foo, 0)
end

########################################################################
################## Multi Thread ########################################
########################################################################

if $single_thread_mode
  puts "All tests (#$import_module) succeeded."
  exit
end

puts "MULTI THREAD TEST"

# Multi Thread, Nesting
module MultiThreadNesting
  module K1mn
    def m; 1; end
    def n; 1; end
  end
  module K2mn
    def m; 2; end
    def n; 2; end
  end
  module K3mn
    def m; 3; end
    def n; 3; end
  end
  class B0mn
    def m; 0; end
    def n; 0; end
  end
  
  thrs = []
  o = B0mn.new
  thrs << Thread.start do
    assert(o.m, 0)
    assert(o.n, 0)
    B0mn.import_module(K1mn) do
      assert(o.m, 1)
      assert(o.n, 1)
    end
    assert(o.m, 0)
    assert(o.n, 0)
    B0mn.import_module(K2mn) do
      assert(o.m, 2)
      assert(o.n, 2)
    end
    assert(o.m, 0)
    assert(o.n, 0)
    thrs << Thread.start do
      assert(o.m, 0)
      assert(o.n, 0)
      B0mn.import_module(K3mn) do
	assert(o.m, 3)
	assert(o.n, 3)
      end
      assert(o.m, 0)
      assert(o.n, 0)
    end
    assert(o.m, 0)
    assert(o.n, 0)
    B0mn.import_module(K2mn) do
      assert(o.m, 2)
      assert(o.n, 2)
    end
  end
  assert(o.m, 0)
  assert(o.n, 0)
  thrs.each do |thr| thr.join end
end

# Do Not Erase Me
module DoNotErace
  class E0m
    def m; 0; end
  end
  module L1m
    def m; 1; end
  end
  o = E0m.new
  thrs = []
  E0m.import_module(L1m) do
    thrs << Thread.new do
      sleep 0.1
      assert(o.m, 1)
    end
  end
  assert(o.m, 0)
  thrs.each do |th| th.join; end
  
  class E2m
    def m; 2; end
  end
  module L3m
    def m; 3; end
  end
  o = E2m.new
  
  thrs = []
  thrs << Thread.new do
    E2m.import_module(L3m) do
      assert(o.m, 3)
    end
  end
  assert(o.m, 2)
  thrs.each do |th| th.join; end
end

# scopes in theads
module ScopesInThreads
  class ST
    def f
      0
    end
  end
  
  module STM
    module M
      def f
	1
      end
    end
  end
  o = ST.new
  thrs = []
  3.times do
    thrs << Thread.start{
      ST.import_module(STM::M) do
	3.times do
	  assert(o.f, 1)
	end
      end
    }
  end
  thrs.each{|th| th.join}
end

# Various Timing
module VariousTiming
  module Mf0
    def f; 0; end
  end
  module Mf1
    def f; 1; end
  end
  module Mf2
    def f; 2; end
  end
  module Mf3
    def f; 3; end
  end
  module Mf4
    def f; 4; end
  end
  module Mf5
    def f; 5; end
  end
  class CMf0
    include Mf0
  end
  o = CMf0.new
  [
    [0.0, 0.0, 0.0, 0.0],
    [0.01, 0.02, 0.0, 0.03],
    [0.02, 0.0, 0.01, 0.0],
    [0.02, 0.01, 0.01, 0.0],
    [0.01, 0.01, 0.01, 0.0],
    [0.01, 0.01, 0.0, 0.01],
    [0.01, 0.0, 0.01, 0.01],
    [0.0, 0.01, 0.01, 0.01],
    [0.01, 0.01, 0.01, 0.01],
  ].each do |a, b, c, d|
    thrs = []
    assert(o.f, 0)
    thrs << Thread.start do
      CMf0.import_module(Mf1) do
	sleep a
	assert(o.f, 1)
	thrs << Thread.start do
	  assert(o.f, 1)
	  CMf0.import_module(Mf2) do
	    assert(o.f, 2)
	    thrs << Thread.start do
	      CMf0.import_module(Mf3) do
		sleep b
		assert(o.f, 3)
	      end
	    end
	    CMf0.import_module(Mf4) do
	      assert(o.f, 4)
	    end
	  end
	end
	sleep c
      end
    end
    sleep d
    assert(o.f, 0)
    thrs.each do |th| th.join; end
  end
end

# Bottom Scope in Deep Thread 
module BottomScope
  class CN0m
    def m; 0; end
  end
  module N1m
    def m; 1; end
  end
  module N2m
    def m; 2; end
  end
  
  o = CN0m.new
  thrs = []
  thrs << Thread.new do
    thrs << Thread.new do
      thrs << Thread.new do
	thrs << Thread.new do
	  CN0m.import_module(N1m) do
	    assert(o.m, 1)
	  end
	end
      end
      sleep 0.1
      CN0m.import_module(N2m) do
	assert(o.m, 2)
      end
    end
  end
  assert(o.m, 0)
  thrs.each do |th| th.join; end
  
  # Many Thread
  class B0m
    def m; 0; end
  end
  module K1m
    def m; 1; end
  end
  o = B0m.new
  thrs = []
  100.times do |n|
    thrs << Thread.start do
      B0m.import_module(K1m) do
	assert(o.m, 1) if n == 99
      end
    end
  end
  thrs.each do |thr|
    thr.join
  end
  #puts B0m.instance_methods
  assert(B0m.instance_methods(false).size, 2)
end

puts "All tests (#$import_module) succeeded."
