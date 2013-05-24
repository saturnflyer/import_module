=begin
= import-module

2005.02.02

*Version: 0.82
*Author: Shin-ichiro HARA
*e-mail: sinara@blade.nagaokaut.ac.jp
*Home Page: ((<URL:http://blade.nagaokaut.ac.jp/~sinara/ruby/import-module/>))

== Introduction

"import-module" enables to incude modules dynamically

== Installation

If you have a unix-like system, do:

  ruby install.rb

You can also install it copying lib/*.rb to the directory where Ruby can load.

== Usage

Do (({reqruire "import-method"})), then ((|Module|)) has following methods:

--- import_module(mod) { ... }
    Includes ((|mod|)) and executes ...

    (Example)
      require "import-module"
      class Foo
        def hello
          puts 'hello'
        end
      end
  
      module Bar
        def hello
          puts 'bye'
        end
      end
  
      module Baz
        def hello
          puts 'good-bye'
        end
      end
  
      foo = Foo.new
      foo.hello                   #=> hello
      Foo.import_module(Bar) do
        foo.hello                 #=> bye
        Foo.import_module(Baz) do
          foo.hello               #=> good-bye
        end
        foo.hello                 #=> bye
      end
      foo.hello                   #=> hello

--- adopt_module(mod)
    Includes ((|mod|)).

    (Example)
      require "import-module"
      class Foo
        def hello
          puts 'hello'
        end
      end
  
      module Bar
        def hello
          puts 'bye'
        end
      end

      foo = Foo.new
      Foo.adopt_module(Bar)
      foo.hello                 #=> bye

((|Object|)) has following methods:

--- import(mod) { ... }
    Extends an object by ((|mod|)), and executes ...

    (Example)
      require "import-module"
      class Foo
        def hello
          puts 'hello'
        end
      end
      
      module Bar
        def hello
          puts 'bye'
        end
      end
      
      foo = Foo.new
      bar = Foo.new
      foo.hello                   #=> hello
      bar.hello                   #=> hello
      foo.import(Bar) do |foo0|
        foo.hello                 #=> bye
        p foo == foo0             #=> true
        bar.hello                 #=> hello
      end
      foo.hello                   #=> hello
      bar.hello                   #=> hello


--- adopt(mod)
    Extends an object by ((|mod|)).

    (Example)
      require "import-module"
      class Foo
        def hello
          puts 'hello'
        end
      end
  
      module Bar
        def hello
          puts 'bye'
        end
      end

      foo = Foo.new
      bar = Foo.new
      foo.adopt(Bar)
      foo.hello                   #=> bye
      bar.hello                   #=> hello

== Multi-threading
This library can be used thread safely.

(Example)
      require "import-module"
      class Foo
        def hello
          puts 'hello'
        end
      end
      
      module Bar
        def hello
          puts 'bye'
        end
      end
      
      foo = Foo.new
      foo.hello #=> hello
      Thread.start do
        Foo.import_module(Bar) do
          foo.hello #=> bye
        end
      end
      foo.hello #=> hello

If you do not use multi-thread, 
set (({$import_module_single_thread = true})) before 
require (({import-module.rb})) or 
use (({import-module-single-thread.rb}))
instead of (({import-module.rb})),
then methods are invoked faster.

== Hint of Use
=== Modify Enumerable
Modify Enumerable module temporary:

      require "import-module"
      module EachChar
       def each(&b); split(//).each(&b); end
      end
      p "abc".import(EachChar){|s| s.map{|x| x.succ}}.join("") #=> "bcd"

#=== Use Original Method
#((|set_orig_method|)) makes a new name for the original method.
#
#      require "import-module"
#      module IndexedEach
#        set_orig_method :_each, :each
#        def each
#          i = 0
#          _each do |x|
#            yield(i, x)
#            i += 1
#          end
#        end
#      end
#      
#      Array.import_module(IndexedEach) do
#        [10, 11, 12].each do |i, x|
#           p [i, x] #=> [0, 10]
#                    #   [1, 11]
#                    #   [2, 12]
#        end
#      end

=== Determinant
Treating the matrix over Integer as over Rational number.

      require "import-module"
      require "matrix"
      require "rational"
      
      module RationalDiv
        def /(other)
          Rational(self) / other
        end
      end
      
      a = Matrix[[2, 1], [3, 1]]
      puts a.det   #=> 0
      Fixnum.import_module(RationalDiv) do
        puts a.det #=> -1
      end
      puts a.det   #=> 0


== Reference

In RAA ((<URL:http://www.ruby-lang.org/en/raa.html>)):

* Ruby Behaviors (David Alan Black)
* scope-in-state (Keiju Ishitsuka)
* class-in-state (Keiju Ishitsuka)

== Changes
0.82 (2005.02.02)
* id => object_id

0.81 (2004.03.10)
* re-package

0.80 (2003.06.29)
* adapted to 1.8.0(preview3)
* adapted to 1.6.8

0.79 (2003.05.02)
* use $import_module_single_thread
* an installer is avalable.

0.78 (2003.05.01)
* fix preserving attribute of method

0.77 (2002.11.05)
* change proxy object from Hash to Array

0.76 (2002.11.01)
* preserve <<protected>>

0.75 (2002.10.31)
* implement set_orig_method

0.74 (2002.10.30)
* Stack#update -> Scope#update
* implement Stack#export_current
* renew test, test-import-module.rb test-time.rb

0.73 (2002.10.28)
* change Stack
* abolish ImportModule#import_module_init
* Thread#__IMPORT_MODULE_PREFIX_proxy, stack
* test scripts changed

0.72 (2002.10.22)
* implement Import_Module::Scope.create
* abolish Scope_module

0.71 (2002.10.20)
* implement Scope_Module
* optimize: &b -> b -> b -> &b
* abolish Import_Module.single_thread
* separate import-module-single-thread.rb

0.70 (2002.10.17)
* Scope(Target, Source)
* import-module-pip.rb
* import-moudle-unbound-method.rb

0.60 (2002.10.15)
* Separate Target, Source, Stack.

0.60beta6 (2002.10.15)
* latest version of "PIP"

0.52 (2002.10.10)
* re-difine target methods
* set "thread safe mode" default
* abolish "thread_safe"
* implement "single_thread_mode"

0.51 (2002.10.09)
* send parameters directly (Import_Module)

0.50 (2002.10.03)
* implement "proxy inheritance pattern" of scope-in-state (Import_Module)
* change stack from 'alias' to Array (Import_Module_Single_Thread)
* abolish '$IMPORT_MODULE_thread_safe'
* implement 'Import_Module.thread_safe'
* Stop 'Super'
=end
