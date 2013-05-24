=begin
= import-module

2005.02.02

*Version: 0.82
*著者: 原　信一郎
*メール: sinara@blade.nagaokaut.ac.jp
*ホームページ: ((<URL:http://blade.nagaokaut.ac.jp/~sinara/ruby/import-module/>))

== 紹介

import-module はモジュールのインクルードを動的に行います。

== インストール

ユニックス系の OS ならば

  ruby install.rb

としてください。また、 lib/*.rb を、ruby が require できる場所に
コピーしても構いません。

== 用法

(({reqruire "import-method"}))をすると((|Module|))に以下のメソッドが
付け加えられます。

--- import_module(mod) { ... }
    ((|mod|)) をモジュールとして取り込んだ状態で ... を実行します。

    (例)
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
    ((|mod|)) をモジュールとして取り込みます。

    (例)
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

また、((|Object|))には次のメソッドが付け加わります。

--- import(mod) { ... }
    オブジェクトに ((|mod|)) をモジュールとして取り込んだ状態で ... を実行します。

    (例)
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
    オブジェクトに ((|mod|)) をモジュールとして取り込みます。

    (例)
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

== マルチスレッド

このライブラリはマルチスレッド対応しています。

(例)
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

マルチスレッド対応が必要でない場合は、
(({$import_module_single_thread = true})) としてから
(({import-module.rb})) を require するか、
(({import-module.rb})) ではなく、
(({import-module-single-thread.rb})) を require してください。
メソッドの呼び出しが早くなります。

== 使い道の例
=== Modify Enumerable
Enumerable の一時的な変更

      require "import-module"
      module EachChar
       def each(&b); split(//).each(&b); end
      end
      p "abc".import(EachChar){|s| s.map{|x| x.succ}}.join("") #=> "bcd"

#=== Use Original Method
#((|set_orig_method|)) でオリジナルなメソッドに名前を付ける。
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
整数値行列をそのまま有理数値行列として扱う。

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


== 参考

RAA ((<URL:http://www.ruby-lang.org/en/raa.html>)) における以下のプログラムを参
考にしました。
* Ruby Behaviors (David Alan Black)
* scope-in-state (Keiju Ishitsuka)
* class-in-state (Keiju Ishitsuka)

== 履歴
0.82 (2005.02.02)
* id => object_id

0.81 (2004.03.10)
* 再パッケージ

0.80 (2003.06.29)
* adapted to 1.8.0(preview3)
* adapted to 1.6.8

0.79 (2003.05.02)
* $import_module_single_thread 導入
* install.rb 添付

0.78 (2003.05.01)
* メソッドの可視性の保存について bug fix

0.77 (2002.11.05)
* proxy object を Hash から Array に変更し高速化

0.76 (2002.11.01)
* 可視性(protected)の保存

0.75 (2002.10.31)
* set_orig_method 導入

0.74 (2002.10.30)
* Stack#update から Scope#update へ移動
* Stack#export_current 導入
* test, test-import-module.rb test-time.rb 書き換え

0.73 (2002.10.28)
* Stack 変更
* ImportModule#import_module_init 廃止
* Thread#__IMPORT_MODULE_PREFIX_proxy, stack 導入
* test scripts 改変

0.72 (2002.10.22)
* Import_Module::Scope.create 導入
* Scope_Module 廃止

0.71 (2002.10.20)
* Scope_Module クラス導入
* optimize: &b -> b -> b -> &b
* import-module-single-thread.rb 分離
* Import_Module.single_thread 廃止

0.70 (2002.10.17)
* Scope クラス導入
* import-module-pip.rb
* import-moudle-unbound-method.rb

0.60 (2002.10.15)
* クラス Target, Source, Stack に分割

0.60beta6 (2002.10.15)
* 代理継承パターン利用の最後

0.52 (2002.10.10)
* ターゲットのメソッドを再定義する方式に
* thread safe mode をデフォルトに
* thread_safe メソッドを廃止
* single_thread_mode メソッドを追加

0.51 (2002.10.09)
* メソッドのパラメータの展開・集約の抑制 (Import_Module)

0.50 (2002.10.03)
* scope-in-state の代理継承パターンの取り入れ (Import_Module)
* stack を alias ベースからモジュールの配列ベースに変更 (Import_Module_Single_Thread)
* $IMPORT_MODULE_thread_safe の廃止
* Import_Module.thread_safe の導入
* Super 機能中止
=end
