#!/usr/local/bin/ruby
import_module = "import-module"
#require "rbprof"
#import_module = "import-module-pip"
$time = 0.0
script = nil
n = 100000
mode = "i"
result = nil

#$IMPORT_MODULE_debug = true
ARGV.delete_if do |x|
  if x =~ /import-module.*\.rb$/
    import_module = x
    mode = "i"
    true
  elsif x =~ /\.rb$/
    import_module = x
    mode = "o"
    true
  elsif x =~ /^\d+$/
    n = x.to_i
    true
  else
    false
  end
end
if x = ARGV.shift
  mode = x
  case mode
  when "b"
    import_module = "b.rb"
  when "s"
#    import_module = "scope-in-state"
#    import_module = "scope-in-state-b"
    import_module = "scope-in-state-ab"
  when "k"
    import_module = "import-module-single-thread"
  when "p", "m"
#    import_module = "t-import-module"
#    import_module = "t-import-module-hit"
    import_module = "import-module-pip"
  when "u"
    import_module = "import-module-unbound-method"
  end
end

start = past = nil

class A
  def foo
    0
  end
end

puts import_module
case mode
when /^[ikup]$/
  require import_module
  module M
    def foo
      1
    end
  end
  a = A.new
#    start = Time.now
  A.import_module(M) do
    result = a.foo
    start = Time.now
    n.times do
      a.foo
    end
    past = Time.now - start
  end

when "s"
  require import_module
  module S
    module A
      def foo
	1
      end
    end
  end
  a = A.new
#  start = Time.now
  s = ScopeInState.new(S)
  s.scope_in do
    start = Time.now
    n.times do
      a.foo
    end
    past = Time.now - start
  end

when "m"
#  puts "(scope module)"
  puts "(scope activate)"
  require import_module
  module M
    def foo
      1
    end
  end
  a = A.new
#  start = Time.now
  s = Import_Module::Scope.create(A, M)
  s.activate do
    result = a.foo
    start = Time.now
    n.times do
      a.foo
    end
    past = Time.now - start
  end

when "o", "b"
  module M
    def foo
      1
    end
  end
  require import_module
  a = A.new
  start = Time.now
  n.times do
    a.foo
  end
  past = Time.now - start
else
  raise "unknown mode"
end
puts past
#puts $time
puts result if result
