# Array Literals
# --------------

# * Array Literals
# * Splats in Array Literals

# TODO: add indexing and method invocation tests: [1][0] is 1, [].toString()

test "trailing commas", ->
  trailingComma = [1, 2, 3,]
  ok (trailingComma[0] is 1) and (trailingComma[2] is 3) and (trailingComma.length is 3)

  trailingComma = [
    1, 2, 3,
    4, 5, 6
    7, 8, 9,
  ]
  (sum = (sum or 0) + n) for n in trailingComma

  a = [((x) -> x), ((x) -> x * x)]
  ok a.length is 2

test "incorrect indentation without commas", ->
  result = [['a']
   {b: 'c'}]
  ok result[0][0] is 'a'
  ok result[1]['b'] is 'c'


# Splats in Array Literals

test "array splat expansions with assignments", ->
  nums = [1, 2, 3]
  list = [a = 0, nums..., b = 4]
  eq 0, a
  eq 4, b
  arrayEq [0,1,2,3,4], list


test "mixed shorthand objects in array lists", ->

  arr = [
    a:1
    'b'
    c:1
  ]
  ok arr.length is 3
  ok arr[2].c is 1

  arr = [b: 1, a: 2, 100]
  eq arr[1], 100

  arr = [a:0, b:1, (1 + 1)]
  eq arr[1], 2

  arr = [a:1, 'a', b:1, 'b']
  eq arr.length, 4
  eq arr[2].b, 1
  eq arr[3], 'b'


test "array splats with nested arrays", ->
  nonce = {}
  a = [nonce]
  list = [1, 2, a...]
  eq list[0], 1
  eq list[2], nonce

  a = [[nonce]]
  list = [1, 2, a...]
  arrayEq list, [1, 2, [nonce]]

test "#1274: `[] = a()` compiles to `false` instead of `a()`", ->
  a = false
  fn = -> a = true
  [] = fn()
  ok a
# Assignment
# ----------

# * Assignment
# * Compound Assignment
# * Destructuring Assignment
# * Context Property (@) Assignment
# * Existential Assignment (?=)

test "context property assignment (using @)", ->
  nonce = {}
  addMethod = ->
    @method = -> nonce
    this
  eq nonce, addMethod.call({}).method()

test "unassignable values", ->
  nonce = {}
  for nonref in ['', '""', '0', 'f()'].concat CoffeeScript.RESERVED
    eq nonce, (try CoffeeScript.compile "#{nonref} = v" catch e then nonce)

# Compound Assignment

test "boolean operators", ->
  nonce = {}

  a  = 0
  a or= nonce
  eq nonce, a

  b  = 1
  b or= nonce
  eq 1, b

  c = 0
  c and= nonce
  eq 0, c

  d = 1
  d and= nonce
  eq nonce, d

  # ensure that RHS is treated as a group
  e = f = false
  e and= f or true
  eq false, e

test "compound assignment as a sub expression", ->
  [a, b, c] = [1, 2, 3]
  eq 6, (a + b += c)
  eq 1, a
  eq 5, b
  eq 3, c

# *note: this test could still use refactoring*
test "compound assignment should be careful about caching variables", ->
  count = 0
  list = []

  list[++count] or= 1
  eq 1, list[1]
  eq 1, count

  list[++count] ?= 2
  eq 2, list[2]
  eq 2, count

  list[count++] and= 6
  eq 6, list[2]
  eq 3, count

  base = ->
    ++count
    base

  base().four or= 4
  eq 4, base.four
  eq 4, count

  base().five ?= 5
  eq 5, base.five
  eq 5, count

  eq 5, base().five ?= 6
  eq 6, count

test "compound assignment with implicit objects", ->
  obj = undefined
  obj ?=
    one: 1

  eq 1, obj.one

  obj and=
    two: 2

  eq undefined, obj.one
  eq         2, obj.two

test "compound assignment (math operators)", ->
  num = 10
  num -= 5
  eq 5, num

  num *= 10
  eq 50, num

  num /= 10
  eq 5, num

  num %= 3
  eq 2, num

test "more compound assignment", ->
  a = {}
  val = undefined
  val ||= a
  val ||= true
  eq a, val

  b = {}
  val &&= true
  eq val, true
  val &&= b
  eq b, val

  c = {}
  val = null
  val ?= c
  val ?= true
  eq c, val


# Destructuring Assignment

test "empty destructuring assignment", ->
  {} = [] = undefined

test "chained destructuring assignments", ->
  [a] = {0: b} = {'0': c} = [nonce={}]
  eq nonce, a
  eq nonce, b
  eq nonce, c

test "variable swapping to verify caching of RHS values when appropriate", ->
  a = nonceA = {}
  b = nonceB = {}
  c = nonceC = {}
  [a, b, c] = [b, c, a]
  eq nonceB, a
  eq nonceC, b
  eq nonceA, c
  [a, b, c] = [b, c, a]
  eq nonceC, a
  eq nonceA, b
  eq nonceB, c
  fn = ->
    [a, b, c] = [b, c, a]
  arrayEq [nonceA,nonceB,nonceC], fn()
  eq nonceA, a
  eq nonceB, b
  eq nonceC, c

test "#713", ->
  nonces = [nonceA={},nonceB={}]
  eq nonces, [a, b] = [c, d] = nonces
  eq nonceA, a
  eq nonceA, c
  eq nonceB, b
  eq nonceB, d

test "destructuring assignment with splats", ->
  a = {}; b = {}; c = {}; d = {}; e = {}
  [x,y...,z] = [a,b,c,d,e]
  eq a, x
  arrayEq [b,c,d], y
  eq e, z

test "deep destructuring assignment with splats", ->
  a={}; b={}; c={}; d={}; e={}; f={}; g={}; h={}; i={}
  [u, [v, w..., x], y..., z] = [a, [b, c, d, e], f, g, h, i]
  eq a, u
  eq b, v
  arrayEq [c,d], w
  eq e, x
  arrayEq [f,g,h], y
  eq i, z

test "destructuring assignment with objects", ->
  a={}; b={}; c={}
  obj = {a,b,c}
  {a:x, b:y, c:z} = obj
  eq a, x
  eq b, y
  eq c, z

test "deep destructuring assignment with objects", ->
  a={}; b={}; c={}; d={}
  obj = {
    a
    b: {
      'c': {
        d: [
          b
          {e: c, f: d}
        ]
      }
    }
  }
  {a: w, 'b': {c: d: [x, {'f': z, e: y}]}} = obj
  eq a, w
  eq b, x
  eq c, y
  eq d, z

test "destructuring assignment with objects and splats", ->
  a={}; b={}; c={}; d={}
  obj = a: b: [a, b, c, d]
  {a: b: [y, z...]} = obj
  eq a, y
  arrayEq [b,c,d], z

test "destructuring assignment against an expression", ->
  a={}; b={}
  [y, z] = if true then [a, b] else [b, a]
  eq a, y
  eq b, z

test "bracket insertion when necessary", ->
  [a] = [0] ? [1]
  eq a, 0

# for implicit destructuring assignment in comprehensions, see the comprehension tests

test "destructuring assignment with context (@) properties", ->
  a={}; b={}; c={}; d={}; e={}
  obj =
    fn: () ->
      local = [a, {b, c}, d, e]
      [@a, {b: @b, c: @c}, @d, @e] = local
  eq undefined, obj[key] for key in ['a','b','c','d','e']
  obj.fn()
  eq a, obj.a
  eq b, obj.b
  eq c, obj.c
  eq d, obj.d
  eq e, obj.e

test "#1024", ->
  eq 2 * [] = 3 + 5, 16

test "#1005: invalid identifiers allowed on LHS of destructuring assignment", ->
  disallowed = ['eval', 'arguments'].concat CoffeeScript.RESERVED
  throws (-> CoffeeScript.compile "[#{disallowed.join ', '}] = x"), null, 'all disallowed'
  throws (-> CoffeeScript.compile "[#{disallowed.join '..., '}...] = x"), null, 'all disallowed as splats'
  t = tSplat = null
  for v in disallowed when v isnt 'class' # `class` by itself is an expression
    throws (-> CoffeeScript.compile t), null, t = "[#{v}] = x"
    throws (-> CoffeeScript.compile tSplat), null, tSplat = "[#{v}...] = x"
  doesNotThrow ->
    for v in disallowed
      CoffeeScript.compile "[a.#{v}] = x"
      CoffeeScript.compile "[a.#{v}...] = x"
      CoffeeScript.compile "[@#{v}] = x"
      CoffeeScript.compile "[@#{v}...] = x"

test "#2055: destructuring assignment with `new`", ->
  {length} = new Array
  eq 0, length

test "#156: destructuring with expansion", ->
  array = [1..5]
  [first, ..., last] = array
  eq 1, first
  eq 5, last
  [..., lastButOne, last] = array
  eq 4, lastButOne
  eq 5, last
  [first, second, ..., last] = array
  eq 2, second
  [..., last] = 'strings as well -> x'
  eq 'x', last
  throws (-> CoffeeScript.compile "[1, ..., 3]"),        null, "prohibit expansion outside of assignment"
  throws (-> CoffeeScript.compile "[..., a, b...] = c"), null, "prohibit expansion and a splat"
  throws (-> CoffeeScript.compile "[...] = c"),          null, "prohibit lone expansion"


# Existential Assignment

test "existential assignment", ->
  nonce = {}
  a = false
  a ?= nonce
  eq false, a
  b = undefined
  b ?= nonce
  eq nonce, b
  c = null
  c ?= nonce
  eq nonce, c

test "#1627: prohibit conditional assignment of undefined variables", ->
  throws (-> CoffeeScript.compile "x ?= 10"),        null, "prohibit (x ?= 10)"
  throws (-> CoffeeScript.compile "x ||= 10"),       null, "prohibit (x ||= 10)"
  throws (-> CoffeeScript.compile "x or= 10"),       null, "prohibit (x or= 10)"
  throws (-> CoffeeScript.compile "do -> x ?= 10"),  null, "prohibit (do -> x ?= 10)"
  throws (-> CoffeeScript.compile "do -> x ||= 10"), null, "prohibit (do -> x ||= 10)"
  throws (-> CoffeeScript.compile "do -> x or= 10"), null, "prohibit (do -> x or= 10)"
  doesNotThrow (-> CoffeeScript.compile "x = null; x ?= 10"),        "allow (x = null; x ?= 10)"
  doesNotThrow (-> CoffeeScript.compile "x = null; x ||= 10"),       "allow (x = null; x ||= 10)"
  doesNotThrow (-> CoffeeScript.compile "x = null; x or= 10"),       "allow (x = null; x or= 10)"
  doesNotThrow (-> CoffeeScript.compile "x = null; do -> x ?= 10"),  "allow (x = null; do -> x ?= 10)"
  doesNotThrow (-> CoffeeScript.compile "x = null; do -> x ||= 10"), "allow (x = null; do -> x ||= 10)"
  doesNotThrow (-> CoffeeScript.compile "x = null; do -> x or= 10"), "allow (x = null; do -> x or= 10)"

  throws (-> CoffeeScript.compile "-> -> -> x ?= 10"), null, "prohibit (-> -> -> x ?= 10)"
  doesNotThrow (-> CoffeeScript.compile "x = null; -> -> -> x ?= 10"), "allow (x = null; -> -> -> x ?= 10)"

test "more existential assignment", ->
  global.temp ?= 0
  eq global.temp, 0
  global.temp or= 100
  eq global.temp, 100
  delete global.temp

test "#1348, #1216: existential assignment compilation", ->
  nonce = {}
  a = nonce
  b = (a ?= 0)
  eq nonce, b
  #the first ?= compiles into a statement; the second ?= compiles to a ternary expression
  eq a ?= b ?= 1, nonce

  if a then a ?= 2 else a = 3
  eq a, nonce

test "#1591, #1101: splatted expressions in destructuring assignment must be assignable", ->
  nonce = {}
  for nonref in ['', '""', '0', 'f()', '(->)'].concat CoffeeScript.RESERVED
    eq nonce, (try CoffeeScript.compile "[#{nonref}...] = v" catch e then nonce)

test "#1643: splatted accesses in destructuring assignments should not be declared as variables", ->
  nonce = {}
  accesses = ['o.a', 'o["a"]', '(o.a)', '(o.a).a', '@o.a', 'C::a', 'C::', 'f().a', 'o?.a', 'o?.a.b', 'f?().a']
  for access in accesses
    for i,j in [1,2,3] #position can matter
      code =
        """
        nonce = {}; nonce2 = {}; nonce3 = {};
        @o = o = new (class C then a:{}); f = -> o
        [#{new Array(i).join('x,')}#{access}...] = [#{new Array(i).join('0,')}nonce, nonce2, nonce3]
        unless #{access}[0] is nonce and #{access}[1] is nonce2 and #{access}[2] is nonce3 then throw new Error('[...]')
        """
      eq nonce, unless (try CoffeeScript.run code, bare: true catch e then true) then nonce
  # subpatterns like `[[a]...]` and `[{a}...]`
  subpatterns = ['[sub, sub2, sub3]', '{0: sub, 1: sub2, 2: sub3}']
  for subpattern in subpatterns
    for i,j in [1,2,3]
      code =
        """
        nonce = {}; nonce2 = {}; nonce3 = {};
        [#{new Array(i).join('x,')}#{subpattern}...] = [#{new Array(i).join('0,')}nonce, nonce2, nonce3]
        unless sub is nonce and sub2 is nonce2 and sub3 is nonce3 then throw new Error('[sub...]')
        """
      eq nonce, unless (try CoffeeScript.run code, bare: true catch e then true) then nonce

test "#1838: Regression with variable assignment", ->
  name =
  'dave'

  eq name, 'dave'

test '#2211: splats in destructured parameters', ->
  doesNotThrow -> CoffeeScript.compile '([a...]) ->'
  doesNotThrow -> CoffeeScript.compile '([a...],b) ->'
  doesNotThrow -> CoffeeScript.compile '([a...],[b...]) ->'
  throws -> CoffeeScript.compile '([a...,[a...]]) ->'
  doesNotThrow -> CoffeeScript.compile '([a...,[b...]]) ->'

test '#2213: invocations within destructured parameters', ->
  throws -> CoffeeScript.compile '([a()])->'
  throws -> CoffeeScript.compile '([a:b()])->'
  throws -> CoffeeScript.compile '([a:b.c()])->'
  throws -> CoffeeScript.compile '({a()})->'
  throws -> CoffeeScript.compile '({a:b()})->'
  throws -> CoffeeScript.compile '({a:b.c()})->'

test '#2532: compound assignment with terminator', ->
  doesNotThrow -> CoffeeScript.compile """
  a = "hello"
  a +=
  "
  world
  !
  "
  """

test "#2613: parens on LHS of destructuring", ->
  a = {}
  [(a).b] = [1, 2, 3]
  eq a.b, 1

test "#2181: conditional assignment as a subexpression", ->
  a = false
  false && a or= true
  eq false, a
  eq false, not a or= true
# Boolean Literals
# ----------------

# TODO: add method invocation tests: true.toString() is "true"

test "#764 Booleans should be indexable", ->
  toString = Boolean::toString

  eq toString, true['toString']
  eq toString, false['toString']
  eq toString, yes['toString']
  eq toString, no['toString']
  eq toString, on['toString']
  eq toString, off['toString']

  eq toString, true.toString
  eq toString, false.toString
  eq toString, yes.toString
  eq toString, no.toString
  eq toString, on.toString
  eq toString, off.toString
# Classes
# -------

# * Class Definition
# * Class Instantiation
# * Inheritance and Super

test "classes with a four-level inheritance chain", ->

  class Base
    func: (string) ->
      "zero/#{string}"

    @static: (string) ->
      "static/#{string}"

  class FirstChild extends Base
    func: (string) ->
      super('one/') + string

  SecondChild = class extends FirstChild
    func: (string) ->
      super('two/') + string

  thirdCtor = ->
    @array = [1, 2, 3]

  class ThirdChild extends SecondChild
    constructor: -> thirdCtor.call this

    # Gratuitous comment for testing.
    func: (string) ->
      super('three/') + string

  result = (new ThirdChild).func 'four'

  ok result is 'zero/one/two/three/four'
  ok Base.static('word') is 'static/word'

  FirstChild::func = (string) ->
    super('one/').length + string

  result = (new ThirdChild).func 'four'

  ok result is '9two/three/four'

  ok (new ThirdChild).array.join(' ') is '1 2 3'


test "constructors with inheritance and super", ->

  identity = (f) -> f

  class TopClass
    constructor: (arg) ->
      @prop = 'top-' + arg

  class SuperClass extends TopClass
    constructor: (arg) ->
      identity super 'super-' + arg

  class SubClass extends SuperClass
    constructor: ->
      identity super 'sub'

  ok (new SubClass).prop is 'top-super-sub'


test "Overriding the static property new doesn't clobber Function::new", ->

  class OneClass
    @new: 'new'
    function: 'function'
    constructor: (name) -> @name = name

  class TwoClass extends OneClass
  delete TwoClass.new

  Function.prototype.new = -> new this arguments...

  ok (TwoClass.new('three')).name is 'three'
  ok (new OneClass).function is 'function'
  ok OneClass.new is 'new'

  delete Function.prototype.new


test "basic classes, again, but in the manual prototype style", ->

  Base = ->
  Base::func = (string) ->
    'zero/' + string
  Base::['func-func'] = (string) ->
    "dynamic-#{string}"

  FirstChild = ->
  SecondChild = ->
  ThirdChild = ->
    @array = [1, 2, 3]
    this

  ThirdChild extends SecondChild extends FirstChild extends Base

  FirstChild::func = (string) ->
    super('one/') + string

  SecondChild::func = (string) ->
    super('two/') + string

  ThirdChild::func = (string) ->
    super('three/') + string

  result = (new ThirdChild).func 'four'

  ok result is 'zero/one/two/three/four'

  ok (new ThirdChild)['func-func']('thing') is 'dynamic-thing'


test "super with plain ol' prototypes", ->

  TopClass = ->
  TopClass::func = (arg) ->
    'top-' + arg

  SuperClass = ->
  SuperClass extends TopClass
  SuperClass::func = (arg) ->
    super 'super-' + arg

  SubClass = ->
  SubClass extends SuperClass
  SubClass::func = ->
    super 'sub'

  eq (new SubClass).func(), 'top-super-sub'


test "'@' referring to the current instance, and not being coerced into a call", ->

  class ClassName
    amI: ->
      @ instanceof ClassName

  obj = new ClassName
  ok obj.amI()


test "super() calls in constructors of classes that are defined as object properties", ->

  class Hive
    constructor: (name) -> @name = name

  class Hive.Bee extends Hive
    constructor: (name) -> super

  maya = new Hive.Bee 'Maya'
  ok maya.name is 'Maya'


test "classes with JS-keyword properties", ->

  class Class
    class: 'class'
    name: -> @class

  instance = new Class
  ok instance.class is 'class'
  ok instance.name() is 'class'


test "Classes with methods that are pre-bound to the instance, or statically, to the class", ->

  class Dog
    constructor: (name) ->
      @name = name

    bark: =>
      "#{@name} woofs!"

    @static = =>
      new this('Dog')

  spark = new Dog('Spark')
  fido  = new Dog('Fido')
  fido.bark = spark.bark

  ok fido.bark() is 'Spark woofs!'

  obj = func: Dog.static

  ok obj.func().name is 'Dog'


test "a bound function in a bound function", ->

  class Mini
    num: 10
    generate: =>
      for i in [1..3]
        =>
          @num

  m = new Mini
  eq (func() for func in m.generate()).join(' '), '10 10 10'


test "contructor called with varargs", ->

  class Connection
    constructor: (one, two, three) ->
      [@one, @two, @three] = [one, two, three]

    out: ->
      "#{@one}-#{@two}-#{@three}"

  list = [3, 2, 1]
  conn = new Connection list...
  ok conn instanceof Connection
  ok conn.out() is '3-2-1'


test "calling super and passing along all arguments", ->

  class Parent
    method: (args...) -> @args = args

  class Child extends Parent
    method: -> super

  c = new Child
  c.method 1, 2, 3, 4
  ok c.args.join(' ') is '1 2 3 4'


test "classes wrapped in decorators", ->

  func = (klass) ->
    klass::prop = 'value'
    klass

  func class Test
    prop2: 'value2'

  ok (new Test).prop  is 'value'
  ok (new Test).prop2 is 'value2'


test "anonymous classes", ->

  obj =
    klass: class
      method: -> 'value'

  instance = new obj.klass
  ok instance.method() is 'value'


test "Implicit objects as static properties", ->

  class Static
    @static =
      one: 1
      two: 2

  ok Static.static.one is 1
  ok Static.static.two is 2


test "nothing classes", ->

  c = class
  ok c instanceof Function


test "classes with static-level implicit objects", ->

  class A
    @static = one: 1
    two: 2

  class B
    @static = one: 1,
    two: 2

  eq A.static.one, 1
  eq A.static.two, undefined
  eq (new A).two, 2

  eq B.static.one, 1
  eq B.static.two, 2
  eq (new B).two, undefined


test "classes with value'd constructors", ->

  counter = 0
  classMaker = ->
    inner = ++counter
    ->
      @value = inner

  class One
    constructor: classMaker()

  class Two
    constructor: classMaker()

  eq (new One).value, 1
  eq (new Two).value, 2
  eq (new One).value, 1
  eq (new Two).value, 2


test "executable class bodies", ->

  class A
    if true
      b: 'b'
    else
      c: 'c'

  a = new A

  eq a.b, 'b'
  eq a.c, undefined


test "#2502: parenthesizing inner object values", ->

  class A
    category:  (type: 'string')
    sections:  (type: 'number', default: 0)

  eq (new A).category.type, 'string'

  eq (new A).sections.default, 0


test "conditional prototype property assignment", ->
  debug = false

  class Person
    if debug
      age: -> 10
    else
      age: -> 20

  eq (new Person).age(), 20


test "mild metaprogramming", ->

  class Base
    @attr: (name) ->
      @::[name] = (val) ->
        if arguments.length > 0
          @["_#{name}"] = val
        else
          @["_#{name}"]

  class Robot extends Base
    @attr 'power'
    @attr 'speed'

  robby = new Robot

  ok robby.power() is undefined

  robby.power 11
  robby.speed Infinity

  eq robby.power(), 11
  eq robby.speed(), Infinity


test "namespaced classes do not reserve their function name in outside scope", ->

  one = {}
  two = {}

  class one.Klass
    @label = "one"

  class two.Klass
    @label = "two"

  eq typeof Klass, 'undefined'
  eq one.Klass.label, 'one'
  eq two.Klass.label, 'two'


test "nested classes", ->

  class Outer
    constructor: ->
      @label = 'outer'

    class @Inner
      constructor: ->
        @label = 'inner'

  eq (new Outer).label, 'outer'
  eq (new Outer.Inner).label, 'inner'


test "variables in constructor bodies are correctly scoped", ->

  class A
    x = 1
    constructor: ->
      x = 10
      y = 20
    y = 2
    captured: ->
      {x, y}

  a = new A
  eq a.captured().x, 10
  eq a.captured().y, 2


test "Issue #924: Static methods in nested classes", ->

  class A
    @B: class
      @c = -> 5

  eq A.B.c(), 5


test "`class extends this`", ->

  class A
    func: -> 'A'

  B = null
  makeClass = ->
    B = class extends this
      func: -> super + ' B'

  makeClass.call A

  eq (new B()).func(), 'A B'


test "ensure that constructors invoked with splats return a new object", ->

  args = [1, 2, 3]
  Type = (@args) ->
  type = new Type args

  ok type and type instanceof Type
  ok type.args and type.args instanceof Array
  ok v is args[i] for v, i in type.args

  Type1 = (@a, @b, @c) ->
  type1 = new Type1 args...

  ok type1 instanceof   Type1
  eq type1.constructor, Type1
  ok type1.a is args[0] and type1.b is args[1] and type1.c is args[2]

  # Ensure that constructors invoked with splats cache the function.
  called = 0
  get = -> if called++ then false else class Type
  new get() args...

test "`new` shouldn't add extra parens", ->

  ok new Date().constructor is Date


test "`new` works against bare function", ->

  eq Date, new ->
    eq this, new => this
    Date


test "#1182: a subclass should be able to set its constructor to an external function", ->
  ctor = ->
    @val = 1
  class A
  class B extends A
    constructor: ctor
  eq (new B).val, 1

test "#1182: external constructors continued", ->
  ctor = ->
  class A
  class B extends A
    method: ->
    constructor: ctor
  ok B::method

test "#1313: misplaced __extends", ->
  nonce = {}
  class A
  class B extends A
    prop: nonce
    constructor: ->
  eq nonce, B::prop

test "#1182: execution order needs to be considered as well", ->
  counter = 0
  makeFn = (n) -> eq n, ++counter; ->
  class B extends (makeFn 1)
    @B: makeFn 2
    constructor: makeFn 3

test "#1182: external constructors with bound functions", ->
  fn = ->
    {one: 1}
    this
  class B
  class A
    constructor: fn
    method: => this instanceof A
  ok (new A).method.call(new B)

test "#1372: bound class methods with reserved names", ->
  class C
    delete: =>
  ok C::delete

test "#1380: `super` with reserved names", ->
  class C
    do: -> super
  ok C::do

  class B
    0: -> super
  ok B::[0]

test "#1464: bound class methods should keep context", ->
  nonce  = {}
  nonce2 = {}
  class C
    constructor: (@id) ->
    @boundStaticColon: => new this(nonce)
    @boundStaticEqual= => new this(nonce2)
  eq nonce,  C.boundStaticColon().id
  eq nonce2, C.boundStaticEqual().id

test "#1009: classes with reserved words as determined names", -> (->
  eq 'function', typeof (class @for)
  ok not /\beval\b/.test (class @eval).toString()
  ok not /\barguments\b/.test (class @arguments).toString()
).call {}

test "#1482: classes can extend expressions", ->
  id = (x) -> x
  nonce = {}
  class A then nonce: nonce
  class B extends id A
  eq nonce, (new B).nonce

test "#1598: super works for static methods too", ->

  class Parent
    method: ->
      'NO'
    @method: ->
      'yes'

  class Child extends Parent
    @method: ->
      'pass? ' + super

  eq Child.method(), 'pass? yes'

test "#1842: Regression with bound functions within bound class methods", ->

  class Store
    @bound: =>
      do =>
        eq this, Store

  Store.bound()

  # And a fancier case:

  class Store

    eq this, Store

    @bound: =>
      do =>
        eq this, Store

    @unbound: ->
      eq this, Store

    instance: =>
      ok this instanceof Store

  Store.bound()
  Store.unbound()
  (new Store).instance()

test "#1876: Class @A extends A", ->
  class A
  class @A extends A

  ok (new @A) instanceof A

test "#1813: Passing class definitions as expressions", ->
  ident = (x) -> x

  result = ident class A then x = 1

  eq result, A

  result = ident class B extends A
    x = 1

  eq result, B

test "#1966: external constructors should produce their return value", ->
  ctor = -> {}
  class A then constructor: ctor
  ok (new A) not instanceof A

test "#1980: regression with an inherited class with static function members", ->

  class A

  class B extends A
    @static: => 'value'

  eq B.static(), 'value'

test "#1534: class then 'use strict'", ->
  # [14.1 Directive Prologues and the Use Strict Directive](http://es5.github.com/#x14.1)
  nonce = {}
  error = 'do -> ok this'
  strictTest = "do ->'use strict';#{error}"
  return unless (try CoffeeScript.run strictTest, bare: yes catch e then nonce) is nonce

  throws -> CoffeeScript.run "class then 'use strict';#{error}", bare: yes
  doesNotThrow -> CoffeeScript.run "class then #{error}", bare: yes
  doesNotThrow -> CoffeeScript.run "class then #{error};'use strict'", bare: yes

  # comments are ignored in the Directive Prologue
  comments = ["""
  class
    ### comment ###
    'use strict'
    #{error}""",
  """
  class
    ### comment 1 ###
    ### comment 2 ###
    'use strict'
    #{error}""",
  """
  class
    ### comment 1 ###
    ### comment 2 ###
    'use strict'
    #{error}
    ### comment 3 ###"""
  ]
  throws (-> CoffeeScript.run comment, bare: yes) for comment in comments

  # [ES5 §14.1](http://es5.github.com/#x14.1) allows for other directives
  directives = ["""
  class
    'directive 1'
    'use strict'
    #{error}""",
  """
  class
    'use strict'
    'directive 2'
    #{error}""",
  """
  class
    ### comment 1 ###
    'directive 1'
    'use strict'
    #{error}""",
  """
  class
    ### comment 1 ###
    'directive 1'
    ### comment 2 ###
    'use strict'
    #{error}"""
  ]
  throws (-> CoffeeScript.run directive, bare: yes) for directive in directives

test "#2052: classes should work in strict mode", ->
  try
    do ->
      'use strict'
      class A
  catch e
    ok no

test "directives in class with extends ", ->
  strictTest = """
    class extends Object
      ### comment ###
      'use strict'
      do -> eq this, undefined
  """
  CoffeeScript.run strictTest, bare: yes

test "#2630: class bodies can't reference arguments", ->
  throws ->
    CoffeeScript.compile('class Test then arguments')

test "#2319: fn class n extends o.p [INDENT] x = 123", ->
  first = ->

  base = onebase: ->

  first class OneKeeper extends base.onebase
    one = 1
    one: -> one

  eq new OneKeeper().one(), 1


test "#2599: other typed constructors should be inherited", ->
  class Base
    constructor: -> return {}

  class Derived extends Base

  ok (new Derived) not instanceof Derived
  ok (new Derived) not instanceof Base
  ok (new Base) not instanceof Base

test "#2359: extending native objects that use other typed constructors requires defining a constructor", ->
  class BrokenArray extends Array
    method: -> 'no one will call me'

  brokenArray = new BrokenArray
  ok brokenArray not instanceof BrokenArray
  ok typeof brokenArray.method is 'undefined'

  class WorkingArray extends Array
    constructor: -> super
    method: -> 'yes!'

  workingArray = new WorkingArray
  ok workingArray instanceof WorkingArray
  eq 'yes!', workingArray.method()


test "#2782: non-alphanumeric-named bound functions", ->
  class A
    'b:c': =>
      'd'

  eq (new A)['b:c'](), 'd'


test "#2781: overriding bound functions", ->
  class A
    a: ->
        @b()
    b: =>
        1

  class B extends A
    b: =>
        2

  b = (new A).b
  eq b(), 1

  b = (new B).b
  eq b(), 2


test "#2791: bound function with destructured argument", ->
  class Foo
    method: ({a}) => 'Bar'

  eq (new Foo).method({a: 'Bar'}), 'Bar'


test "#2796: ditto, ditto, ditto", ->
  answer = null

  outsideMethod = (func) ->
    func.call message: 'wrong!'

  class Base
    constructor: ->
      @message = 'right!'
      outsideMethod @echo

    echo: =>
      answer = @message

  new Base
  eq answer, 'right!'

test "#3063: Class bodies cannot contain pure statements", ->
  throws -> CoffeeScript.compile """
    class extends S
      return if S.f
      @f: => this
  """

test "#2949: super in static method with reserved name", ->
  class Foo
    @static: -> 'baz'

  class Bar extends Foo
    @static: -> super

  eq Bar.static(), 'baz'

test "#3232: super in static methods (not object-assigned)", ->
  class Foo
    @baz = -> true
    @qux = -> true

  class Bar extends Foo
    @baz = -> super
    Bar.qux = -> super

  ok Bar.baz()
  ok Bar.qux()
# Cluster Module
# ---------

return if testingBrowser?

cluster = require 'cluster'

if cluster.isMaster
  test "#2737 - cluster module can spawn workers from a coffeescript process", ->
    cluster.once 'exit', (worker, code) ->
      eq code, 0

    cluster.fork()
else
  process.exit 0
# Comments
# --------

# * Single-Line Comments
# * Block Comments

# Note: awkward spacing seen in some tests is likely intentional.

test "comments in objects", ->
  obj1 = {
  # comment
    # comment
      # comment
    one: 1
  # comment
    two: 2
      # comment
  }

  ok Object::hasOwnProperty.call(obj1,'one')
  eq obj1.one, 1
  ok Object::hasOwnProperty.call(obj1,'two')
  eq obj1.two, 2

test "comments in YAML-style objects", ->
  obj2 =
  # comment
    # comment
      # comment
    three: 3
  # comment
    four: 4
      # comment

  ok Object::hasOwnProperty.call(obj2,'three')
  eq obj2.three, 3
  ok Object::hasOwnProperty.call(obj2,'four')
  eq obj2.four, 4

test "comments following operators that continue lines", ->
  sum =
    1 +
    1 + # comment
    1
  eq 3, sum

test "comments in functions", ->
  fn = ->
  # comment
    false
    false   # comment
    false
    # comment

  # comment
    true

  ok fn()

  fn2 = -> #comment
    fn()
    # comment

  ok fn2()

test "trailing comment before an outdent", ->
  nonce = {}
  fn3 = ->
    if true
      undefined # comment
    nonce

  eq nonce, fn3()

test "comments in a switch", ->
  nonce = {}
  result = switch nonce #comment
    # comment
    when false then undefined
    # comment
    when null #comment
      undefined
    else nonce # comment

  eq nonce, result

test "comment with conditional statements", ->
  nonce = {}
  result = if false # comment
    undefined
  #comment
  else # comment
    nonce
    # comment
  eq nonce, result

test "spaced comments with conditional statements", ->
  nonce = {}
  result = if false
    undefined

  # comment
  else if false
    undefined

  # comment
  else
    nonce

  eq nonce, result


# Block Comments

###
  This is a here-comment.
  Kind of like a heredoc.
###

test "block comments in objects", ->
  a = {}
  b = {}
  obj = {
    a: a
    ###
    comment
    ###
    b: b
  }

  eq a, obj.a
  eq b, obj.b

test "block comments in YAML-style", ->
  a = {}
  b = {}
  obj =
    a: a
    ###
    comment
    ###
    b: b

  eq a, obj.a
  eq b, obj.b


test "block comments in functions", ->
  nonce = {}

  fn1 = ->
    true
    ###
    false
    ###

  ok fn1()

  fn2 =  ->
    ###
    block comment
    ###
    nonce

  eq nonce, fn2()

  fn3 = ->
    nonce
  ###
  block comment
  ###

  eq nonce, fn3()

  fn4 = ->
    one = ->
      ###
        block comment
      ###
      two = ->
        three = ->
          nonce

  eq nonce, fn4()()()()

test "block comments inside class bodies", ->
  class A
    a: ->

    ###
    Comment
    ###
    b: ->

  ok A.prototype.b instanceof Function

  class B
    ###
    Comment
    ###
    a: ->
    b: ->

  ok B.prototype.a instanceof Function

test "#2037: herecomments shouldn't imply line terminators", ->
  do (-> ### ###; fail)

test "#2916: block comment before implicit call with implicit object", ->
  fn = (obj) -> ok obj.a
  ### ###
  fn
    a: yes

test "#3132: Format single-line block comment nicely", ->
  input = """
  ### Single-line block comment without additional space here => ###"""

  result = """

  /* Single-line block comment without additional space here => */


  """
  eq CoffeeScript.compile(input, bare: on), result

test "#3132: Format multi-line block comment nicely", ->
  input = """
  ###
  # Multi-line
  # block
  # comment
  ###"""

  result = """

  /*
   * Multi-line
   * block
   * comment
   */


  """
  eq CoffeeScript.compile(input, bare: on), result

test "#3132: Format simple block comment nicely", ->
  input = """
  ###
  No
  Preceding hash
  ###"""

  result = """

  /*
  No
  Preceding hash
   */


  """

  eq CoffeeScript.compile(input, bare: on), result

test "#3132: Format indented block-comment nicely", ->
  input = """
  fn = () ->
    ###
    # Indented
    Multiline
    ###
    1"""

  result = """
  var fn;

  fn = function() {

    /*
     * Indented
    Multiline
     */
    return 1;
  };

  """
  eq CoffeeScript.compile(input, bare: on), result

# Although adequately working, block comment-placement is not yet perfect.
# (Considering a case where multiple variables have been declared …)
test "#3132: Format jsdoc-style block-comment nicely", ->
  input = """
  ###*
  # Multiline for jsdoc-"@doctags"
  # 
  # @type {Function}
  ###
  fn = () -> 1
  """

  result = """
  
  /**
   * Multiline for jsdoc-"@doctags"
   * 
   * @type {Function}
   */
  var fn;
  
  fn = function() {
    return 1;
  };
  
  """
  eq CoffeeScript.compile(input, bare: on), result

# Although adequately working, block comment-placement is not yet perfect.
# (Considering a case where multiple variables have been declared …)
test "#3132: Format hand-made (raw) jsdoc-style block-comment nicely", ->
  input = """
  ###*
   * Multiline for jsdoc-"@doctags"
   * 
   * @type {Function}
  ###
  fn = () -> 1
  """

  result = """
  
  /**
   * Multiline for jsdoc-"@doctags"
   * 
   * @type {Function}
   */
  var fn;
  
  fn = function() {
    return 1;
  };
  
  """
  eq CoffeeScript.compile(input, bare: on), result

# Although adequately working, block comment-placement is not yet perfect.
# (Considering a case where multiple variables have been declared …)
test "#3132: Place block-comments nicely", ->
  input = """
  ###*
  # A dummy class definition
  # 
  # @class
  ###
  class DummyClass
    
    ###*
    # @constructor
    ###
    constructor: ->
  
    ###*
    # Singleton reference
    # 
    # @type {DummyClass}
    ###
    @instance = new DummyClass()
  
  """

  result = """
  
  /**
   * A dummy class definition
   * 
   * @class
   */
  var DummyClass;
  
  DummyClass = (function() {
  
    /**
     * @constructor
     */
    function DummyClass() {}
  
  
    /**
     * Singleton reference
     * 
     * @type {DummyClass}
     */
  
    DummyClass.instance = new DummyClass();
  
    return DummyClass;
  
  })();
  
  """
  eq CoffeeScript.compile(input, bare: on), result
# Compilation
# -----------

# helper to assert that a string should fail compilation
cantCompile = (code) ->
  throws -> CoffeeScript.compile code


test "ensure that carriage returns don't break compilation on Windows", ->
  doesNotThrow -> CoffeeScript.compile 'one\r\ntwo', bare: on

test "#3089 - don't mutate passed in options to compile", ->
  opts = {}
  CoffeeScript.compile '1 + 1', opts
  ok !opts.scope 

test "--bare", ->
  eq -1, CoffeeScript.compile('x = y', bare: on).indexOf 'function'
  ok 'passed' is CoffeeScript.eval '"passed"', bare: on, filename: 'test'

test "header (#1778)", ->
  header = "// Generated by CoffeeScript #{CoffeeScript.VERSION}\n"
  eq 0, CoffeeScript.compile('x = y', header: on).indexOf header

test "header is disabled by default", ->
  header = "// Generated by CoffeeScript #{CoffeeScript.VERSION}\n"
  eq -1, CoffeeScript.compile('x = y').indexOf header

test "multiple generated references", ->
  a = {b: []}
  a.b[true] = -> this == a.b
  c = 0
  d = []
  ok a.b[0<++c<2] d...

test "splat on a line by itself is invalid", ->
  cantCompile "x 'a'\n...\n"

test "Issue 750", ->

  cantCompile 'f(->'

  cantCompile 'a = (break)'

  cantCompile 'a = (return 5 for item in list)'

  cantCompile 'a = (return 5 while condition)'

  cantCompile 'a = for x in y\n  return 5'

test "Issue #986: Unicode identifiers", ->
  λ = 5
  eq λ, 5

test "don't accidentally stringify keywords", ->
  ok (-> this == 'this')() is false

test "#1026", ->
  cantCompile '''
    if a
      b
    else
      c
    else
      d
  '''

test "#1050", ->
  cantCompile "### */ ###"

test "#1273: escaping quotes at the end of heredocs", ->
  cantCompile '"""\\"""' # """\"""
  cantCompile '"""\\\\\\"""' # """\\\"""

test "#1106: __proto__ compilation", ->
  object = eq
  @["__proto__"] = true
  ok __proto__

test "reference named hasOwnProperty", ->
  CoffeeScript.compile 'hasOwnProperty = 0; a = 1'

test "#1055: invalid keys in real (but not work-product) objects", ->
  cantCompile "@key: value"

test "#1066: interpolated strings are not implicit functions", ->
  cantCompile '"int#{er}polated" arg'

test "#2846: while with empty body", ->
  CoffeeScript.compile 'while 1 then', {sourceMap: true}

test "#2944: implicit call with a regex argument", ->
  CoffeeScript.compile 'o[key] /regex/'

test "#3001: `own` shouldn't be allowed in a `for`-`in` loop", ->
  cantCompile "a for own b in c"

test "#2994: single-line `if` requires `then`", ->
  cantCompile "if b else x"
# Comprehensions
# --------------

# * Array Comprehensions
# * Range Comprehensions
# * Object Comprehensions
# * Implicit Destructuring Assignment
# * Comprehensions with Nonstandard Step

# TODO: refactor comprehension tests

test "Basic array comprehensions.", ->

  nums    = (n * n for n in [1, 2, 3] when n & 1)
  results = (n * 2 for n in nums)

  ok results.join(',') is '2,18'


test "Basic object comprehensions.", ->

  obj   = {one: 1, two: 2, three: 3}
  names = (prop + '!' for prop of obj)
  odds  = (prop + '!' for prop, value of obj when value & 1)

  ok names.join(' ') is "one! two! three!"
  ok odds.join(' ')  is "one! three!"


test "Basic range comprehensions.", ->

  nums = (i * 3 for i in [1..3])

  negs = (x for x in [-20..-5*2])
  negs = negs[0..2]

  result = nums.concat(negs).join(', ')

  ok result is '3, 6, 9, -20, -19, -18'


test "With range comprehensions, you can loop in steps.", ->

  results = (x for x in [0...15] by 5)
  ok results.join(' ') is '0 5 10'

  results = (x for x in [0..100] by 10)
  ok results.join(' ') is '0 10 20 30 40 50 60 70 80 90 100'


test "And can loop downwards, with a negative step.", ->

  results = (x for x in [5..1])

  ok results.join(' ') is '5 4 3 2 1'
  ok results.join(' ') is [(10-5)..(-2+3)].join(' ')

  results = (x for x in [10..1])
  ok results.join(' ') is [10..1].join(' ')

  results = (x for x in [10...0] by -2)
  ok results.join(' ') is [10, 8, 6, 4, 2].join(' ')


test "Range comprehension gymnastics.", ->

  eq "#{i for i in [5..1]}", '5,4,3,2,1'
  eq "#{i for i in [5..-5] by -5}", '5,0,-5'

  a = 6
  b = 0
  c = -2

  eq "#{i for i in [a..b]}", '6,5,4,3,2,1,0'
  eq "#{i for i in [a..b] by c}", '6,4,2,0'


test "Multiline array comprehension with filter.", ->

  evens = for num in [1, 2, 3, 4, 5, 6] when not (num & 1)
             num *= -1
             num -= 2
             num * -1
  eq evens + '', '4,6,8'


  test "The in operator still works, standalone.", ->

    ok 2 of evens


test "all isn't reserved.", ->

  all = 1


test "Ensure that the closure wrapper preserves local variables.", ->

  obj = {}

  for method in ['one', 'two', 'three'] then do (method) ->
    obj[method] = ->
      "I'm " + method

  ok obj.one()   is "I'm one"
  ok obj.two()   is "I'm two"
  ok obj.three() is "I'm three"


test "Index values at the end of a loop.", ->

  i = 0
  for i in [1..3]
    -> 'func'
    break if false
  ok i is 4


test "Ensure that local variables are closed over for range comprehensions.", ->

  funcs = for i in [1..3]
    do (i) ->
      -> -i

  eq (func() for func in funcs).join(' '), '-1 -2 -3'
  ok i is 4


test "Even when referenced in the filter.", ->

  list = ['one', 'two', 'three']

  methods = for num, i in list when num isnt 'two' and i isnt 1
    do (num, i) ->
      -> num + ' ' + i

  ok methods.length is 2
  ok methods[0]() is 'one 0'
  ok methods[1]() is 'three 2'


test "Even a convoluted one.", ->

  funcs = []

  for i in [1..3]
    do (i) ->
      x = i * 2
      ((z)->
        funcs.push -> z + ' ' + i
      )(x)

  ok (func() for func in funcs).join(', ') is '2 1, 4 2, 6 3'

  funcs = []

  results = for i in [1..3]
    do (i) ->
      z = (x * 3 for x in [1..i])
      ((a, b, c) -> [a, b, c].join(' ')).apply this, z

  ok results.join(', ') is '3  , 3 6 , 3 6 9'


test "Naked ranges are expanded into arrays.", ->

  array = [0..10]
  ok(num % 2 is 0 for num in array by 2)


test "Nested shared scopes.", ->

  foo = ->
    for i in [0..7]
      do (i) ->
        for j in [0..7]
          do (j) ->
            -> i + j

  eq foo()[3][4](), 7


test "Scoped loop pattern matching.", ->

  a = [[0], [1]]
  funcs = []

  for [v] in a
    do (v) ->
      funcs.push -> v

  eq funcs[0](), 0
  eq funcs[1](), 1


test "Nested comprehensions.", ->

  multiLiner =
    for x in [3..5]
      for y in [3..5]
        [x, y]

  singleLiner =
    (([x, y] for y in [3..5]) for x in [3..5])

  ok multiLiner.length is singleLiner.length
  ok 5 is multiLiner[2][2][1]
  ok 5 is singleLiner[2][2][1]


test "Comprehensions within parentheses.", ->

  result = null
  store = (obj) -> result = obj
  store (x * 2 for x in [3, 2, 1])

  ok result.join(' ') is '6 4 2'


test "Closure-wrapped comprehensions that refer to the 'arguments' object.", ->

  expr = ->
    result = (item * item for item in arguments)

  ok expr(2, 4, 8).join(' ') is '4 16 64'


test "Fast object comprehensions over all properties, including prototypal ones.", ->

  class Cat
    constructor: -> @name = 'Whiskers'
    breed: 'tabby'
    hair:  'cream'

  whiskers = new Cat
  own = (value for own key, value of whiskers)
  all = (value for key, value of whiskers)

  ok own.join(' ') is 'Whiskers'
  ok all.sort().join(' ') is 'Whiskers cream tabby'


test "Optimized range comprehensions.", ->

  exxes = ('x' for [0...10])
  ok exxes.join(' ') is 'x x x x x x x x x x'


test "Loop variables should be able to reference outer variables", ->
  outer = 1
  do ->
    null for outer in [1, 2, 3]
  eq outer, 3


test "Lenient on pure statements not trying to reach out of the closure", ->

  val = for i in [1]
    for j in [] then break
    i
  ok val[0] is i


test "Comprehensions only wrap their last line in a closure, allowing other lines
  to have pure expressions in them.", ->

  func = -> for i in [1]
    break if i is 2
    j for j in [1]

  ok func()[0][0] is 1

  i = 6
  odds = while i--
    continue unless i & 1
    i

  ok odds.join(', ') is '5, 3, 1'


test "Issue #897: Ensure that plucked function variables aren't leaked.", ->

  facets = {}
  list = ['one', 'two']

  (->
    for entity in list
      facets[entity] = -> entity
  )()

  eq typeof entity, 'undefined'
  eq facets['two'](), 'two'


test "Issue #905. Soaks as the for loop subject.", ->

  a = {b: {c: [1, 2, 3]}}
  for d in a.b?.c
    e = d

  eq e, 3


test "Issue #948. Capturing loop variables.", ->

  funcs = []
  list  = ->
    [1, 2, 3]

  for y in list()
    do (y) ->
      z = y
      funcs.push -> "y is #{y} and z is #{z}"

  eq funcs[1](), "y is 2 and z is 2"


test "Cancel the comprehension if there's a jump inside the loop.", ->

  result = try
    for i in [0...10]
      continue if i < 5
    i

  eq result, 10


test "Comprehensions over break.", ->

  arrayEq (break for [1..10]), []


test "Comprehensions over continue.", ->

  arrayEq (continue for [1..10]), []


test "Comprehensions over function literals.", ->

  a = 0
  for f in [-> a = 1]
    do (f) ->
      do f

  eq a, 1


test "Comprehensions that mention arguments.", ->

  list = [arguments: 10]
  args = for f in list
    do (f) ->
      f.arguments
  eq args[0], 10


test "expression conversion under explicit returns", ->
  nonce = {}
  fn = ->
    return (nonce for x in [1,2,3])
  arrayEq [nonce,nonce,nonce], fn()
  fn = ->
    return [nonce for x in [1,2,3]][0]
  arrayEq [nonce,nonce,nonce], fn()
  fn = ->
    return [(nonce for x in [1..3])][0]
  arrayEq [nonce,nonce,nonce], fn()


test "implicit destructuring assignment in object of objects", ->
  a={}; b={}; c={}
  obj = {
    a: { d: a },
    b: { d: b }
    c: { d: c }
  }
  result = ([y,z] for y, { d: z } of obj)
  arrayEq [['a',a],['b',b],['c',c]], result


test "implicit destructuring assignment in array of objects", ->
  a={}; b={}; c={}; d={}; e={}; f={}
  arr = [
    { a: a, b: { c: b } },
    { a: c, b: { c: d } },
    { a: e, b: { c: f } }
  ]
  result = ([y,z] for { a: y, b: { c: z } } in arr)
  arrayEq [[a,b],[c,d],[e,f]], result


test "implicit destructuring assignment in array of arrays", ->
  a={}; b={}; c={}; d={}; e={}; f={}
  arr = [[a, [b]], [c, [d]], [e, [f]]]
  result = ([y,z] for [y, [z]] in arr)
  arrayEq [[a,b],[c,d],[e,f]], result

test "issue #1124: don't assign a variable in two scopes", ->
  lista = [1, 2, 3, 4, 5]
  listb = (_i + 1 for _i in lista)
  arrayEq [2, 3, 4, 5, 6], listb

test "#1326: `by` value is uncached", ->
  a = [0,1,2]
  fi = gi = hi = 0
  f = -> ++fi
  g = -> ++gi
  h = -> ++hi

  forCompile = []
  rangeCompileSimple = []

  #exercises For.compile
  for v, i in a by f()
    forCompile.push i

  #exercises Range.compileSimple
  rangeCompileSimple = (i for i in [0..2] by g())

  arrayEq a, forCompile
  arrayEq a, rangeCompileSimple
  #exercises Range.compile
  eq "#{i for i in [0..2] by h()}", '0,1,2'

test "#1669: break/continue should skip the result only for that branch", ->
  ns = for n in [0..99]
    if n > 9
      break
    else if n & 1
      continue
    else
      n
  eq "#{ns}", '0,2,4,6,8'

  # `else undefined` is implied.
  ns = for n in [1..9]
    if n % 2
      continue unless n % 5
      n
  eq "#{ns}", "1,,3,,,7,,9"

  # Ditto.
  ns = for n in [1..9]
    switch
      when n % 2
        continue unless n % 5
        n
  eq "#{ns}", "1,,3,,,7,,9"

test "#1850: inner `for` should not be expression-ized if `return`ing", ->
  eq '3,4,5', do ->
    for a in [1..9] then \
    for b in [1..9]
      c = Math.sqrt a*a + b*b
      return String [a, b, c] unless c % 1

test "#1910: loop index should be mutable within a loop iteration and immutable between loop iterations", ->
  n = 1
  iterations = 0
  arr = [0..n]
  for v, k in arr
    ++iterations
    v = k = 5
    eq 5, k
  eq 2, k
  eq 2, iterations

  iterations = 0
  for v in [0..n]
    ++iterations
  eq 2, k
  eq 2, iterations

  arr = ([v, v + 1] for v in [0..5])
  iterations = 0
  for [v0, v1], k in arr when v0
    k += 3
    ++iterations
  eq 6, k
  eq 5, iterations

test "#2007: Return object literal from comprehension", ->
  y = for x in [1, 2]
    foo: "foo" + x
  eq 2, y.length
  eq "foo1", y[0].foo
  eq "foo2", y[1].foo

  x = 2
  y = while x
    x: --x
  eq 2, y.length
  eq 1, y[0].x
  eq 0, y[1].x

test "#2274: Allow @values as loop variables", ->
  obj = {
    item: null
    method: ->
      for @item in [1, 2, 3]
        null
  }
  eq obj.item, null
  obj.method()
  eq obj.item, 3

test "#2525, #1187, #1208, #1758, looping over an array forwards", ->
  list = [0, 1, 2, 3, 4]

  ident = (x) -> x

  arrayEq (i for i in list), list

  arrayEq (index for i, index in list), list

  arrayEq (i for i in list by 1), list

  arrayEq (i for i in list by ident 1), list

  arrayEq (i for i in list by ident(1) * 2), [0, 2, 4]

  arrayEq (index for i, index in list by ident(1) * 2), [0, 2, 4]

test "#2525, #1187, #1208, #1758, looping over an array backwards", ->
  list = [0, 1, 2, 3, 4]
  backwards = [4, 3, 2, 1, 0]

  ident = (x) -> x

  arrayEq (i for i in list by -1), backwards

  arrayEq (index for i, index in list by -1), backwards

  arrayEq (i for i in list by ident -1), backwards

  arrayEq (i for i in list by ident(-1) * 2), [4, 2, 0]

  arrayEq (index for i, index in list by ident(-1) * 2), [4, 2, 0]

test "splats in destructuring in comprehensions", ->
  list = [[0, 1, 2], [2, 3, 4], [4, 5, 6]]
  arrayEq (seq for [rep, seq...] in list), [[1, 2], [3, 4], [5, 6]]

test "#156: expansion in destructuring in comprehensions", ->
  list = [[0, 1, 2], [2, 3, 4], [4, 5, 6]]
  arrayEq (last for [..., last] in list), [2, 4, 6]
# Control Flow
# ------------

# * Conditionals
# * Loops
#   * For
#   * While
#   * Until
#   * Loop
# * Switch
# * Throw

# TODO: make sure postfix forms and expression coercion are properly tested

# shared identity function
id = (_) -> if arguments.length is 1 then _ else Array::slice.call(arguments)

# Conditionals

test "basic conditionals", ->
  if false
    ok false
  else if false
    ok false
  else
    ok true

  if true
    ok true
  else if true
    ok false
  else
    ok true

  unless true
    ok false
  else unless true
    ok false
  else
    ok true

  unless false
    ok true
  else unless false
    ok false
  else
    ok true

test "single-line conditional", ->
  if false then ok false else ok true
  unless false then ok true else ok false

test "nested conditionals", ->
  nonce = {}
  eq nonce, (if true
    unless false
      if false then false else
        if true
          nonce)

test "nested single-line conditionals", ->
  nonce = {}

  a = if false then undefined else b = if 0 then undefined else nonce
  eq nonce, a
  eq nonce, b

  c = if false then undefined else (if 0 then undefined else nonce)
  eq nonce, c

  d = if true then id(if false then undefined else nonce)
  eq nonce, d

test "empty conditional bodies", ->
  eq undefined, (if false
  else if false
  else)

test "conditional bodies containing only comments", ->
  eq undefined, (if true
    ###
    block comment
    ###
  else
    # comment
  )

  eq undefined, (if false
    # comment
  else if true
    ###
    block comment
    ###
  else)

test "return value of if-else is from the proper body", ->
  nonce = {}
  eq nonce, if false then undefined else nonce

test "return value of unless-else is from the proper body", ->
  nonce = {}
  eq nonce, unless true then undefined else nonce

test "assign inside the condition of a conditional statement", ->
  nonce = {}
  if a = nonce then 1
  eq nonce, a
  1 if b = nonce
  eq nonce, b


# Interactions With Functions

test "single-line function definition with single-line conditional", ->
  fn = -> if 1 < 0.5 then 1 else -1
  ok fn() is -1

test "function resturns conditional value with no `else`", ->
  fn = ->
    return if false then true
  eq undefined, fn()

test "function returns a conditional value", ->
  a = {}
  fnA = ->
    return if false then undefined else a
  eq a, fnA()

  b = {}
  fnB = ->
    return unless false then b else undefined
  eq b, fnB()

test "passing a conditional value to a function", ->
  nonce = {}
  eq nonce, id if false then undefined else nonce

test "unmatched `then` should catch implicit calls", ->
  a = 0
  trueFn = -> true
  if trueFn undefined then a++
  eq 1, a


# if-to-ternary

test "if-to-ternary with instanceof requires parentheses", ->
  nonce = {}
  eq nonce, (if {} instanceof Object
    nonce
  else
    undefined)

test "if-to-ternary as part of a larger operation requires parentheses", ->
  ok 2, 1 + if false then 0 else 1


# Odd Formatting

test "if-else indented within an assignment", ->
  nonce = {}
  result =
    if false
      undefined
    else
      nonce
  eq nonce, result

test "suppressed indentation via assignment", ->
  nonce = {}
  result =
    if      false then undefined
    else if no    then undefined
    else if 0     then undefined
    else if 1 < 0 then undefined
    else               id(
         if false then undefined
         else          nonce
    )
  eq nonce, result

test "tight formatting with leading `then`", ->
  nonce = {}
  eq nonce,
  if true
  then nonce
  else undefined

test "#738", ->
  nonce = {}
  fn = if true then -> nonce
  eq nonce, fn()

test "#748: trailing reserved identifiers", ->
  nonce = {}
  obj = delete: true
  result = if obj.delete
    nonce
  eq nonce, result

# Postfix

test "#3056: multiple postfix conditionals", ->
  temp = 'initial'
  temp = 'ignored' unless true if false
  eq temp, 'initial'

# Loops

test "basic `while` loops", ->

  i = 5
  list = while i -= 1
    i * 2
  ok list.join(' ') is "8 6 4 2"

  i = 5
  list = (i * 3 while i -= 1)
  ok list.join(' ') is "12 9 6 3"

  i = 5
  func   = (num) -> i -= num
  assert = -> ok i < 5 > 0
  results = while func 1
    assert()
    i
  ok results.join(' ') is '4 3 2 1'

  i = 10
  results = while i -= 1 when i % 2 is 0
    i * 2
  ok results.join(' ') is '16 12 8 4'


test "Issue 759: `if` within `while` condition", ->

  2 while if 1 then 0


test "assignment inside the condition of a `while` loop", ->

  nonce = {}
  count = 1
  a = nonce while count--
  eq nonce, a
  count = 1
  while count--
    b = nonce
  eq nonce, b


test "While over break.", ->

  i = 0
  result = while i < 10
    i++
    break
  arrayEq result, []


test "While over continue.", ->

  i = 0
  result = while i < 10
    i++
    continue
  arrayEq result, []


test "Basic `until`", ->

  value = false
  i = 0
  results = until value
    value = true if i is 5
    i++
  ok i is 6


test "Basic `loop`", ->

  i = 5
  list = []
  loop
    i -= 1
    break if i is 0
    list.push i * 2
  ok list.join(' ') is '8 6 4 2'


test "break at the top level", ->
  for i in [1,2,3]
    result = i
    if i == 2
      break
  eq 2, result

test "break *not* at the top level", ->
  someFunc = ->
    i = 0
    while ++i < 3
      result = i
      break if i > 1
    result
  eq 2, someFunc()

# Switch

test "basic `switch`", ->

  num = 10
  result = switch num
    when 5 then false
    when 'a'
      true
      true
      false
    when 10 then true


    # Mid-switch comment with whitespace
    # and multi line
    when 11 then false
    else false

  ok result


  func = (num) ->
    switch num
      when 2, 4, 6
        true
      when 1, 3, 5
        false

  ok func(2)
  ok func(6)
  ok !func(3)
  eq func(8), undefined


test "Ensure that trailing switch elses don't get rewritten.", ->

  result = false
  switch "word"
    when "one thing"
      doSomething()
    else
      result = true unless false

  ok result

  result = false
  switch "word"
    when "one thing"
      doSomething()
    when "other thing"
      doSomething()
    else
      result = true unless false

  ok result


test "Should be able to handle switches sans-condition.", ->

  result = switch
    when null                     then 0
    when !1                       then 1
    when '' not of {''}           then 2
    when [] not instanceof Array  then 3
    when true is false            then 4
    when 'x' < 'y' > 'z'          then 5
    when 'a' in ['b', 'c']        then 6
    when 'd' in (['e', 'f'])      then 7
    else ok

  eq result, ok


test "Should be able to use `@properties` within the switch clause.", ->

  obj = {
    num: 101
    func: ->
      switch @num
        when 101 then '101!'
        else 'other'
  }

  ok obj.func() is '101!'


test "Should be able to use `@properties` within the switch cases.", ->

  obj = {
    num: 101
    func: (yesOrNo) ->
      result = switch yesOrNo
        when yes then @num
        else 'other'
      result
  }

  ok obj.func(yes) is 101


test "Switch with break as the return value of a loop.", ->

  i = 10
  results = while i > 0
    i--
    switch i % 2
      when 1 then i
      when 0 then break

  eq results.join(', '), '9, 7, 5, 3, 1'


test "Issue #997. Switch doesn't fallthrough.", ->

  val = 1
  switch true
    when true
      if false
        return 5
    else
      val = 2

  eq val, 1

# Throw

test "Throw should be usable as an expression.", ->
  try
    false or throw 'up'
    throw new Error 'failed'
  catch e
    ok e is 'up'


test "#2555, strange function if bodies", ->
  success = -> ok true
  failure = -> ok false

  success() if do ->
    yes

  failure() if try
    false

test "#1057: `catch` or `finally` in single-line functions", ->
  ok do -> try throw 'up' catch then yes
  ok do -> try yes finally 'nothing'

test "#2367: super in for-loop", ->
  class Foo
    sum: 0
    add: (val) -> @sum += val

  class Bar extends Foo
    add: (vals...) ->
      super val for val in vals
      @sum

  eq 10, (new Bar).add 2, 3, 5
# Error Formating
# ---------------

# Ensure that errors of different kinds (lexer, parser and compiler) are shown
# in a consistent way.

assertErrorFormat = (code, expectedErrorFormat) ->
  throws (-> CoffeeScript.run code), (err) ->
    err.colorful = no
    eq expectedErrorFormat, "#{err}"
    yes

test "lexer errors formating", ->
  assertErrorFormat '''
    normalObject    = {}
    insideOutObject = }{
  ''',
  '''
    [stdin]:2:19: error: unmatched }
    insideOutObject = }{
                      ^
  '''

test "parser error formating", ->
  assertErrorFormat '''
    foo in bar or in baz
  ''',
  '''
    [stdin]:1:15: error: unexpected in
    foo in bar or in baz
                  ^^
  '''

test "compiler error formatting", ->
  assertErrorFormat '''
    evil = (foo, eval, bar) ->
  ''',
  '''
    [stdin]:1:14: error: parameter name "eval" is not allowed
    evil = (foo, eval, bar) ->
                 ^^^^
  '''


if require?
  fs   = require 'fs'
  path = require 'path'

  test "patchStackTrace line patching", ->
    err = new Error 'error'
    ok err.stack.match /test[\/\\]error_messages\.coffee:\d+:\d+\b/

  test "patchStackTrace stack prelude consistent with V8", ->
    err = new Error
    ok err.stack.match /^Error\n/ # Notice no colon when no message.

    err = new Error 'error'
    ok err.stack.match /^Error: error\n/

  test "#2849: compilation error in a require()d file", ->
    # Create a temporary file to require().
    ok not fs.existsSync 'test/syntax-error.coffee'
    fs.writeFileSync 'test/syntax-error.coffee', 'foo in bar or in baz'

    try
      assertErrorFormat '''
        require './test/syntax-error'
      ''',
      """
        #{path.join __dirname, 'syntax-error.coffee'}:1:15: error: unexpected in
        foo in bar or in baz
                      ^^
      """
    finally
      fs.unlink 'test/syntax-error.coffee'


test "#1096: unexpected generated tokens", ->
  # Unexpected interpolation
  assertErrorFormat '{"#{key}": val}', '''
    [stdin]:1:3: error: unexpected string interpolation
    {"#{key}": val}
      ^^
  '''
  # Implicit ends
  assertErrorFormat 'a:, b', '''
    [stdin]:1:3: error: unexpected ,
    a:, b
      ^
  '''
  # Explicit ends
  assertErrorFormat '(a:)', '''
    [stdin]:1:4: error: unexpected )
    (a:)
       ^
  '''
  # Unexpected end of file
  assertErrorFormat 'a:', '''
    [stdin]:1:3: error: unexpected end of input
    a:
      ^
  '''
  # Unexpected implicit object
  assertErrorFormat '''
    for i in [1]:
      1
  ''', '''
    [stdin]:1:13: error: unexpected :
    for i in [1]:
                ^
  '''

test "#3325: implicit indentation errors", ->
  assertErrorFormat '''
    i for i in a then i
  ''', '''
    [stdin]:1:14: error: unexpected then
    i for i in a then i
                 ^^^^
  '''

test "explicit indentation errors", ->
  assertErrorFormat '''
    a = b
      c
  ''', '''
    [stdin]:2:1: error: unexpected indentation
      c
    ^^
  '''
if vm = require? 'vm'

  test "CoffeeScript.eval runs in the global context by default", ->
    global.punctuation = '!'
    code = '''
    global.fhqwhgads = "global superpower#{global.punctuation}"
    '''
    result = CoffeeScript.eval code
    eq result, 'global superpower!'
    eq fhqwhgads, 'global superpower!'

  test "CoffeeScript.eval can run in, and modify, a Script context sandbox", ->
    sandbox = vm.Script.createContext()
    sandbox.foo = 'bar'
    code = '''
    global.foo = 'not bar!'
    '''
    result = CoffeeScript.eval code, {sandbox}
    eq result, 'not bar!'
    eq sandbox.foo, 'not bar!'

  test "CoffeeScript.eval can run in, but cannot modify, an ordinary object sandbox", ->
    sandbox = {foo: 'bar'}
    code = '''
    global.foo = 'not bar!'
    '''
    result = CoffeeScript.eval code, {sandbox}
    eq result, 'not bar!'
    eq sandbox.foo, 'bar'
# Exception Handling
# ------------------

# shared nonce
nonce = {}


# Throw

test "basic exception throwing", ->
  throws (-> throw 'error'), 'error'


# Empty Try/Catch/Finally

test "try can exist alone", ->
  try

test "try/catch with empty try, empty catch", ->
  try
    # nothing
  catch err
    # nothing

test "single-line try/catch with empty try, empty catch", ->
  try catch err

test "try/finally with empty try, empty finally", ->
  try
    # nothing
  finally
    # nothing

test "single-line try/finally with empty try, empty finally", ->
  try finally

test "try/catch/finally with empty try, empty catch, empty finally", ->
  try
  catch err
  finally

test "single-line try/catch/finally with empty try, empty catch, empty finally", ->
  try catch err then finally


# Try/Catch/Finally as an Expression

test "return the result of try when no exception is thrown", ->
  result = try
    nonce
  catch err
    undefined
  finally
    undefined
  eq nonce, result

test "single-line result of try when no exception is thrown", ->
  result = try nonce catch err then undefined
  eq nonce, result

test "return the result of catch when an exception is thrown", ->
  fn = ->
    try
      throw ->
    catch err
      nonce
  doesNotThrow fn
  eq nonce, fn()

test "single-line result of catch when an exception is thrown", ->
  fn = ->
    try throw (->) catch err then nonce
  doesNotThrow fn
  eq nonce, fn()

test "optional catch", ->
  fn = ->
    try throw ->
    nonce
  doesNotThrow fn
  eq nonce, fn()


# Try/Catch/Finally Interaction With Other Constructs

test "try/catch with empty catch as last statement in a function body", ->
  fn = ->
    try nonce
    catch err
  eq nonce, fn()


# Catch leads to broken scoping: #1595

test "try/catch with a reused variable name.", ->
  do ->
    try
      inner = 5
    catch inner
      # nothing
  eq typeof inner, 'undefined'


# Allowed to destructure exceptions: #2580

test "try/catch with destructuring the exception object", ->

  result = try
    missing.object
  catch {message}
    message

  eq message, 'missing is not defined'



test "Try catch finally as implicit arguments", ->
  first = (x) -> x

  foo = no
  try
    first try iamwhoiam() finally foo = yes
  catch e
  eq foo, yes

  bar = no
  try
    first try iamwhoiam() catch e finally
    bar = yes
  catch e
  eq bar, yes

# Catch Should Not Require Param: #2900
test "parameter-less catch clause", ->
  try
    throw new Error 'failed'
  catch
    ok true

  try throw new Error 'failed' catch finally ok true

  ok try throw new Error 'failed' catch then true
# Formatting
# ----------

# TODO: maybe this file should be split up into their respective sections:
#   operators -> operators
#   array literals -> array literals
#   string literals -> string literals
#   function invocations -> function invocations

doesNotThrow -> CoffeeScript.compile "a = then b"

test "multiple semicolon-separated statements in parentheticals", ->
  nonce = {}
  eq nonce, (1; 2; nonce)
  eq nonce, (-> return (1; 2; nonce))()

# * Line Continuation
#   * Property Accesss
#   * Operators
#   * Array Literals
#   * Function Invocations
#   * String Literals

# Property Access

test "chained accesses split on period/newline, backwards and forwards", ->
  str = 'abc'
  result = str.
    split('').
    reverse().
    reverse().
    reverse()
  arrayEq ['c','b','a'], result
  arrayEq ['c','b','a'], str.
    split('').
    reverse().
    reverse().
    reverse()
  result = str
    .split('')
    .reverse()
    .reverse()
    .reverse()
  arrayEq ['c','b','a'], result
  arrayEq ['c','b','a'],
    str
    .split('')
    .reverse()
    .reverse()
    .reverse()
  arrayEq ['c','b','a'],
    str.
    split('')
    .reverse().
    reverse()
    .reverse()

# Operators

test "newline suppression for operators", ->
  six =
    1 +
    2 +
    3
  eq 6, six

test "`?.` and `::` should continue lines", ->
  ok not (
    Date
    ::
    ?.foo
  )
  #eq Object::toString, Date?.
  #prototype
  #::
  #?.foo

doesNotThrow -> CoffeeScript.compile """
  oh. yes
  oh?. true
  oh:: return
  """

doesNotThrow -> CoffeeScript.compile """
  a?[b..]
  a?[...b]
  a?[b..c]
  """

# Array Literals

test "indented array literals don't trigger whitespace rewriting", ->
  getArgs = -> arguments
  result = getArgs(
    [[[[[],
                  []],
                [[]]]],
      []])
  eq 1, result.length

# Function Invocations

doesNotThrow -> CoffeeScript.compile """
  obj = then fn 1,
    1: 1
    a:
      b: ->
        fn c,
          d: e
    f: 1
  """

# String Literals

test "indented heredoc", ->
  result = ((_) -> _)(
                """
                abc
                """)
  eq "abc", result

# Chaining - all open calls are closed by property access starting a new line
# * chaining after
#   * indented argument
#   * function block
#   * indented object
#
#   * single line arguments
#   * inline function literal
#   * inline object literal

test "chaining after outdent", ->
  id = (x) -> x

  # indented argument
  ff = id parseInt "ff",
    16
  .toString()
  eq '255', ff

  # function block
  str = 'abc'
  zero = parseInt str.replace /\w/, (letter) ->
    0
  .toString()
  eq '0', zero

  # indented object
  a = id id
    a: 1
  .a
  eq 1, a

test "#1495, method call chaining", ->
  str = 'abc'

  result = str.split ''
              .join ', '
  eq 'a, b, c', result

  result = str
  .split ''
  .join ', '
  eq 'a, b, c', result

  eq 'a, b, c', (str
    .split ''
    .join ', '
  )

  eq 'abc',
    'aaabbbccc'.replace /(\w)\1\1/g, '$1$1'
               .replace /([abc])\1/g, '$1'

  # Nested calls
  result = [1..3]
    .slice Math.max 0, 1
    .concat [3]
  arrayEq [2, 3, 3], result

  # Single line function arguments
  result = [1..6]
    .map (x) -> x * x
    .filter (x) -> x % 2 is 0
    .reverse()
  arrayEq [36, 16, 4], result

  # Single line implicit objects
  id = (x) -> x
  result = id a: 1
    .a
  eq 1, result

  # The parens are forced
  result = str.split(''.
    split ''
    .join ''
  ).join ', '
  eq 'a, b, c', result

# Nested blocks caused by paren unwrapping
test "#1492: Nested blocks don't cause double semicolons", ->
  js = CoffeeScript.compile '(0;0)'
  eq -1, js.indexOf ';;'

test "#1195 Ignore trailing semicolons (before newlines or as the last char in a program)", ->
  preNewline = (numSemicolons) ->
    """
    nonce = {}; nonce2 = {}
    f = -> nonce#{Array(numSemicolons+1).join(';')}
    nonce2
    unless f() is nonce then throw new Error('; before linebreak should = newline')
    """
  CoffeeScript.run(preNewline(n), bare: true) for n in [1,2,3]

  lastChar = '-> lastChar;'
  doesNotThrow -> CoffeeScript.compile lastChar, bare: true

test "#1299: Disallow token misnesting", ->
  try
    CoffeeScript.compile '''
      [{
         ]}
    '''
    ok no
  catch e
    eq 'unmatched ]', e.message

test "#2981: Enforce initial indentation", ->
  try
    CoffeeScript.compile '  a\nb-'
    ok no
  catch e
    eq 'missing indentation', e.message

test "'single-line' expression containing multiple lines", ->
  doesNotThrow -> CoffeeScript.compile """
    (a, b) -> if a
      -a
    else if b
    then -b
    else null
  """

test "#1275: allow indentation before closing brackets", ->
  array = [
      1
      2
      3
    ]
  eq array, array
  do ->
  (
    a = 1
   )
  eq 1, a
# Function Invocation
# -------------------

# * Function Invocation
# * Splats in Function Invocations
# * Implicit Returns
# * Explicit Returns

# shared identity function
id = (_) -> if arguments.length is 1 then _ else [arguments...]

# helper to assert that a string should fail compilation
cantCompile = (code) ->
  throws -> CoffeeScript.compile code

test "basic argument passing", ->

  a = {}
  b = {}
  c = {}
  eq 1, (id 1)
  eq 2, (id 1, 2)[1]
  eq a, (id a)
  eq c, (id a, b, c)[2]


test "passing arguments on separate lines", ->

  a = {}
  b = {}
  c = {}
  ok(id(
    a
    b
    c
  )[1] is b)
  eq(0, id(
    0
    10
  )[0])
  eq(a,id(
    a
  ))
  eq b,
  (id b)


test "optional parens can be used in a nested fashion", ->

  call = (func) -> func()
  add = (a,b) -> a + b
  result = call ->
    inner = call ->
      add 5, 5
  ok result is 10


test "hanging commas and semicolons in argument list", ->

  fn = () -> arguments.length
  eq 2, fn(0,1,)
  eq 3, fn 0, 1,
  2
  eq 2, fn(0, 1;)
  # TODO: this test fails (the string compiles), but should it?
  #throws -> CoffeeScript.compile "fn(0,1,;)"
  throws -> CoffeeScript.compile "fn(0,1,;;)"
  throws -> CoffeeScript.compile "fn(0, 1;,)"
  throws -> CoffeeScript.compile "fn(,0)"
  throws -> CoffeeScript.compile "fn(;0)"


test "function invocation", ->

  func = ->
    return if true
  eq undefined, func()

  result = ("hello".slice) 3
  ok result is 'lo'


test "And even with strange things like this:", ->

  funcs  = [((x) -> x), ((x) -> x * x)]
  result = funcs[1] 5
  ok result is 25


test "More fun with optional parens.", ->

  fn = (arg) -> arg
  ok fn(fn {prop: 101}).prop is 101

  okFunc = (f) -> ok(f())
  okFunc -> true


test "chained function calls", ->
  nonce = {}
  identityWrap = (x) ->
    -> x
  eq nonce, identityWrap(identityWrap(nonce))()()
  eq nonce, (identityWrap identityWrap nonce)()()


test "Multi-blocks with optional parens.", ->

  fn = (arg) -> arg
  result = fn( ->
    fn ->
      "Wrapped"
  )
  ok result()() is 'Wrapped'


test "method calls", ->

  fnId = (fn) -> -> fn.apply this, arguments
  math = {
    add: (a, b) -> a + b
    anonymousAdd: (a, b) -> a + b
    fastAdd: fnId (a, b) -> a + b
  }
  ok math.add(5, 5) is 10
  ok math.anonymousAdd(10, 10) is 20
  ok math.fastAdd(20, 20) is 40


test "Ensure that functions can have a trailing comma in their argument list", ->

  mult = (x, mids..., y) ->
    x *= n for n in mids
    x *= y
  #ok mult(1, 2,) is 2
  #ok mult(1, 2, 3,) is 6
  ok mult(10, (i for i in [1..6])...) is 7200


test "`@` and `this` should both be able to invoke a method", ->
  nonce = {}
  fn          = (arg) -> eq nonce, arg
  fn.withAt   = -> @ nonce
  fn.withThis = -> this nonce
  fn.withAt()
  fn.withThis()


test "Trying an implicit object call with a trailing function.", ->

  a = null
  meth = (arg, obj, func) -> a = [obj.a, arg, func()].join ' '
  meth 'apple', b: 1, a: 13, ->
    'orange'
  ok a is '13 apple orange'


test "Ensure that empty functions don't return mistaken values.", ->

  obj =
    func: (@param, @rest...) ->
  ok obj.func(101, 102, 103, 104) is undefined
  ok obj.param is 101
  ok obj.rest.join(' ') is '102 103 104'


test "Passing multiple functions without paren-wrapping is legal, and should compile.", ->

  sum = (one, two) -> one() + two()
  result = sum ->
    7 + 9
  , ->
    1 + 3
  ok result is 20


test "Implicit call with a trailing if statement as a param.", ->

  func = -> arguments[1]
  result = func 'one', if false then 100 else 13
  ok result is 13


test "Test more function passing:", ->

  sum = (one, two) -> one() + two()

  result = sum( ->
    1 + 2
  , ->
    2 + 1
  )
  ok result is 6

  sum = (a, b) -> a + b
  result = sum(1
  , 2)
  ok result is 3


test "Chained blocks, with proper indentation levels:", ->

  counter =
    results: []
    tick: (func) ->
      @results.push func()
      this
  counter
    .tick ->
      3
    .tick ->
      2
    .tick ->
      1
  arrayEq [3,2,1], counter.results


test "This is a crazy one.", ->

  x = (obj, func) -> func obj
  ident = (x) -> x
  result = x {one: ident 1}, (obj) ->
    inner = ident(obj)
    ident inner
  ok result.one is 1


test "More paren compilation tests:", ->

  reverse = (obj) -> obj.reverse()
  ok reverse([1, 2].concat 3).join(' ') is '3 2 1'


test "Test for inline functions with parentheses and implicit calls.", ->

  combine = (func, num) -> func() * num
  result  = combine (-> 1 + 2), 3
  ok result is 9


test "Test for calls/parens/multiline-chains.", ->

  f = (x) -> x
  result = (f 1).toString()
    .length
  ok result is 1


test "Test implicit calls in functions in parens:", ->

  result = ((val) ->
    [].push val
    val
  )(10)
  ok result is 10


test "Ensure that chained calls with indented implicit object literals below are alright.", ->

  result = null
  obj =
    method: (val)  -> this
    second: (hash) -> result = hash.three
  obj
    .method(
      101
    ).second(
      one:
        two: 2
      three: 3
    )
  eq result, 3


test "Test newline-supressed call chains with nested functions.", ->

  obj  =
    call: -> this
  func = ->
    obj
      .call ->
        one two
      .call ->
        three four
    101
  eq func(), 101


test "Implicit objects with number arguments.", ->

  func = (x, y) -> y
  obj =
    prop: func "a", 1
  ok obj.prop is 1


test "Non-spaced unary and binary operators should cause a function call.", ->

  func = (val) -> val + 1
  ok (func +5) is 6
  ok (func -5) is -4


test "Prefix unary assignment operators are allowed in parenless calls.", ->

  func = (val) -> val + 1
  val = 5
  ok (func --val) is 5

test "#855: execution context for `func arr...` should be `null`", ->
  contextTest = -> eq @, if window? then window else global
  array = []
  contextTest array
  contextTest.apply null, array
  contextTest array...

test "#904: Destructuring function arguments with same-named variables in scope", ->
  a = b = nonce = {}
  fn = ([a,b]) -> {a:a,b:b}
  result = fn([c={},d={}])
  eq c, result.a
  eq d, result.b
  eq nonce, a
  eq nonce, b

test "Simple Destructuring function arguments with same-named variables in scope", ->
  x = 1
  f = ([x]) -> x
  eq f([2]), 2
  eq x, 1

test "caching base value", ->

  obj =
    index: 0
    0: {method: -> this is obj[0]}
  ok obj[obj.index++].method([]...)


test "passing splats to functions", ->
  arrayEq [0..4], id id [0..4]...
  fn = (a, b, c..., d) -> [a, b, c, d]
  range = [0..3]
  [first, second, others, last] = fn range..., 4, [5...8]...
  eq 0, first
  eq 1, second
  arrayEq [2..6], others
  eq 7, last

test "splat variables are local to the function", ->
  outer = "x"
  clobber = (avar, outer...) -> outer
  clobber "foo", "bar"
  eq "x", outer


test "Issue 894: Splatting against constructor-chained functions.", ->

  x = null
  class Foo
    bar: (y) -> x = y
  new Foo().bar([101]...)
  eq x, 101


test "Functions with splats being called with too few arguments.", ->

  pen = null
  method = (first, variable..., penultimate, ultimate) ->
    pen = penultimate
  method 1, 2, 3, 4, 5, 6, 7, 8, 9
  ok pen is 8
  method 1, 2, 3
  ok pen is 2
  method 1, 2
  ok pen is 2


test "splats with super() within classes.", ->

  class Parent
    meth: (args...) ->
      args
  class Child extends Parent
    meth: ->
      nums = [3, 2, 1]
      super nums...
  ok (new Child).meth().join(' ') is '3 2 1'


test "#1011: passing a splat to a method of a number", ->
  eq '1011', 11.toString [2]...
  eq '1011', (31).toString [3]...
  eq '1011', 69.0.toString [4]...
  eq '1011', (131.0).toString [5]...


test "splats and the `new` operator: functions that return `null` should construct their instance", ->
  args = []
  child = new (constructor = -> null) args...
  ok child instanceof constructor

test "splats and the `new` operator: functions that return functions should construct their return value", ->
  args = []
  fn = ->
  child = new (constructor = -> fn) args...
  ok child not instanceof constructor
  eq fn, child

test "implicit return", ->

  eq ok, new ->
    ok
    ### Should `return` implicitly   ###
    ### even with trailing comments. ###


test "implicit returns with multiple branches", ->
  nonce = {}
  fn = ->
    if false
      for a in b
        return c if d
    else
      nonce
  eq nonce, fn()


test "implicit returns with switches", ->
  nonce = {}
  fn = ->
    switch nonce
      when nonce then nonce
      else return undefined
  eq nonce, fn()


test "preserve context when generating closure wrappers for expression conversions", ->
  nonce = {}
  obj =
    property: nonce
    method: ->
      this.result = if false
        10
      else
        "a"
        "b"
        this.property
  eq nonce, obj.method()
  eq nonce, obj.property


test "don't wrap 'pure' statements in a closure", ->
  nonce = {}
  items = [0, 1, 2, 3, nonce, 4, 5]
  fn = (items) ->
    for item in items
      return item if item is nonce
  eq nonce, fn items


test "usage of `new` is careful about where the invocation parens end up", ->
  eq 'object', typeof new try Array
  eq 'object', typeof new do -> ->


test "implicit call against control structures", ->
  result = null
  save   = (obj) -> result = obj

  save switch id false
    when true
      'true'
    when false
      'false'

  eq result, 'false'

  save if id false
    'false'
  else
    'true'

  eq result, 'true'

  save unless id false
    'true'
  else
    'false'

  eq result, 'true'

  save try
    doesnt exist
  catch error
    'caught'

  eq result, 'caught'

  save try doesnt(exist) catch error then 'caught2'

  eq result, 'caught2'


test "#1420: things like `(fn() ->)`; there are no words for this one", ->
  fn = -> (f) -> f()
  nonce = {}
  eq nonce, (fn() -> nonce)

test "#1416: don't omit one 'new' when compiling 'new new'", ->
  nonce = {}
  obj = new new -> -> {prop: nonce}
  eq obj.prop, nonce

test "#1416: don't omit one 'new' when compiling 'new new fn()()'", ->
  nonce = {}
  argNonceA = {}
  argNonceB = {}
  fn = (a) -> (b) -> {a, b, prop: nonce}
  obj = new new fn(argNonceA)(argNonceB)
  eq obj.prop, nonce
  eq obj.a, argNonceA
  eq obj.b, argNonceB

test "#1840: accessing the `prototype` after function invocation should compile", ->
  doesNotThrow -> CoffeeScript.compile 'fn()::prop'

  nonce = {}
  class Test then id: nonce

  dotAccess = -> Test::
  protoAccess = -> Test

  eq dotAccess().id, nonce
  eq protoAccess()::id, nonce

test "#960: improved 'do'", ->

  do (nonExistent = 'one') ->
    eq nonExistent, 'one'

  overridden = 1
  do (overridden = 2) ->
    eq overridden, 2

  two = 2
  do (one = 1, two, three = 3) ->
    eq one, 1
    eq two, 2
    eq three, 3

  ret = do func = (two) ->
    eq two, 2
    func
  eq ret, func

test "#2617: implicit call before unrelated implicit object", ->
  pass = ->
    true

  result = if pass 1
    one: 1
  eq result.one, 1

test "#2292, b: f (z),(x)", ->
  f = (x, y) -> y
  one = 1
  two = 2
  o = b: f (one),(two)
  eq o.b, 2

test "#2297, Different behaviors on interpreting literal", ->
  foo = (x, y) -> y
  bar =
    baz: foo 100, on

  eq bar.baz, on

  qux = (x) -> x
  quux = qux
    corge: foo 100, true

  eq quux.corge, on

  xyzzy =
    e: 1
    f: foo
      a: 1
      b: 2
    ,
      one: 1
      two: 2
      three: 3
    g:
      a: 1
      b: 2
      c: foo 2,
        one: 1
        two: 2
        three: 3
      d: 3
    four: 4
    h: foo one: 1, two: 2, three: three: three: 3,
      2

  eq xyzzy.f.two, 2
  eq xyzzy.g.c.three, 3
  eq xyzzy.four, 4
  eq xyzzy.h, 2

test "#2715, Chained implicit calls", ->
  first  = (x)    -> x
  second = (x, y) -> y

  foo = first first
    one: 1
  eq foo.one, 1

  bar = first second
    one: 1, 2
  eq bar, 2

  baz = first second
    one: 1,
    2
  eq baz, 2

test "Implicit calls and new", ->
  first = (x) -> x
  foo = (@x) ->
  bar = first new foo first 1
  eq bar.x, 1

  third = (x, y, z) -> z
  baz = first new foo new foo third
        one: 1
        two: 2
        1
        three: 3
        2
  eq baz.x.x.three, 3

test "Loose tokens inside of explicit call lists", ->
  first = (x) -> x
  second = (x, y) -> y
  one = 1

  foo = second( one
                2)
  eq foo, 2
  
  bar = first( first
               one: 1)

test "Non-callable literals shouldn't compile", ->
  cantCompile '1(2)'
  cantCompile '1 2'
  cantCompile '/t/(2)'
  cantCompile '/t/ 2'
  cantCompile '///t///(2)'
  cantCompile '///t/// 2'
  cantCompile "''(2)"
  cantCompile "'' 2"
  cantCompile '""(2)'
  cantCompile '"" 2'
  cantCompile '""""""(2)'
  cantCompile '"""""" 2'
  cantCompile '{}(2)'
  cantCompile '{} 2'
  cantCompile '[](2)'
  cantCompile '[] 2'
  cantCompile '[2..9] 2'
  cantCompile '[2..9](2)'
  cantCompile '[1..10][2..9] 2'
  cantCompile '[1..10][2..9](2)'
# Function Literals
# -----------------

# TODO: add indexing and method invocation tests: (->)[0], (->).call()

# * Function Definition
# * Bound Function Definition
# * Parameter List Features
#   * Splat Parameters
#   * Context (@) Parameters
#   * Parameter Destructuring
#   * Default Parameters

# Function Definition

x = 1
y = {}
y.x = -> 3
ok x is 1
ok typeof(y.x) is 'function'
ok y.x instanceof Function
ok y.x() is 3

# The empty function should not cause a syntax error.
->
() ->

# Multiple nested function declarations mixed with implicit calls should not
# cause a syntax error.
(one) -> (two) -> three four, (five) -> six seven, eight, (nine) ->

# with multiple single-line functions on the same line.
func = (x) -> (x) -> (x) -> x
ok func(1)(2)(3) is 3

# Make incorrect indentation safe.
func = ->
  obj = {
          key: 10
        }
  obj.key - 5
eq func(), 5

# Ensure that functions with the same name don't clash with helper functions.
del = -> 5
ok del() is 5


# Bound Function Definition

obj =
  bound: ->
    (=> this)()
  unbound: ->
    (-> this)()
  nested: ->
    (=>
      (=>
        (=> this)()
      )()
    )()
eq obj, obj.bound()
ok obj isnt obj.unbound()
eq obj, obj.nested()


test "even more fancy bound functions", ->
  obj =
    one: ->
      do =>
        return this.two()
    two: ->
      do =>
        do =>
          do =>
            return this.three
    three: 3

  eq obj.one(), 3


test "self-referencing functions", ->
  changeMe = ->
    changeMe = 2

  changeMe()
  eq changeMe, 2


# Parameter List Features

test "splats", ->
  arrayEq [0, 1, 2], (((splat...) -> splat) 0, 1, 2)
  arrayEq [2, 3], (((_, _1, splat...) -> splat) 0, 1, 2, 3)
  arrayEq [0, 1], (((splat..., _, _1) -> splat) 0, 1, 2, 3)
  arrayEq [2], (((_, _1, splat..., _2) -> splat) 0, 1, 2, 3)

test "destructured splatted parameters", ->
  arr = [0,1,2]
  splatArray = ([a...]) -> a
  splatArrayRest = ([a...],b...) -> arrayEq(a,b); b
  arrayEq splatArray(arr), arr
  arrayEq splatArrayRest(arr,0,1,2), arr

test "@-parameters: automatically assign an argument's value to a property of the context", ->
  nonce = {}

  ((@prop) ->).call context = {}, nonce
  eq nonce, context.prop

  # allow splats along side the special argument
  ((splat..., @prop) ->).apply context = {}, [0, 0, nonce]
  eq nonce, context.prop

  # allow the argument itself to be a splat
  ((@prop...) ->).call context = {}, 0, nonce, 0
  eq nonce, context.prop[1]

  # the argument should still be able to be referenced normally
  eq nonce, (((@prop) -> prop).call {}, nonce)

test "@-parameters and splats with constructors", ->
  a = {}
  b = {}
  class Klass
    constructor: (@first, splat..., @last) ->

  obj = new Klass a, 0, 0, b
  eq a, obj.first
  eq b, obj.last

test "destructuring in function definition", ->
  (([{a: [b], c}]...) ->
    eq 1, b
    eq 2, c
  ) {a: [1], c: 2}

test "default values", ->
  nonceA = {}
  nonceB = {}
  a = (_,_1,arg=nonceA) -> arg
  eq nonceA, a()
  eq nonceA, a(0)
  eq nonceB, a(0,0,nonceB)
  eq nonceA, a(0,0,undefined)
  eq nonceA, a(0,0,null)
  eq false , a(0,0,false)
  eq nonceB, a(undefined,undefined,nonceB,undefined)
  b = (_,arg=nonceA,_1,_2) -> arg
  eq nonceA, b()
  eq nonceA, b(0)
  eq nonceB, b(0,nonceB)
  eq nonceA, b(0,undefined)
  eq nonceA, b(0,null)
  eq false , b(0,false)
  eq nonceB, b(undefined,nonceB,undefined)
  c = (arg=nonceA,_,_1) -> arg
  eq nonceA, c()
  eq      0, c(0)
  eq nonceB, c(nonceB)
  eq nonceA, c(undefined)
  eq nonceA, c(null)
  eq false , c(false)
  eq nonceB, c(nonceB,undefined,undefined)

test "default values with @-parameters", ->
  a = {}
  b = {}
  obj = f: (q = a, @p = b) -> q
  eq a, obj.f()
  eq b, obj.p

test "default values with splatted arguments", ->
  withSplats = (a = 2, b..., c = 3, d = 5) -> a * (b.length + 1) * c * d
  eq 30, withSplats()
  eq 15, withSplats(1)
  eq  5, withSplats(1,1)
  eq  1, withSplats(1,1,1)
  eq  2, withSplats(1,1,1,1)

test "#156: parameter lists with expansion", ->
  expandArguments = (first, ..., lastButOne, last) ->
    eq 1, first
    eq 4, lastButOne
    last
  eq 5, expandArguments 1, 2, 3, 4, 5

  throws (-> CoffeeScript.compile "(..., a, b...) ->"), null, "prohibit expansion and a splat"
  throws (-> CoffeeScript.compile "(...) ->"),          null, "prohibit lone expansion"

test "#156: parameter lists with expansion in array destructuring", ->
  expandArray = (..., [..., last]) ->
    last
  eq 3, expandArray 1, 2, 3, [1, 2, 3]

test "default values with function calls", ->
  doesNotThrow -> CoffeeScript.compile "(x = f()) ->"

test "arguments vs parameters", ->
  doesNotThrow -> CoffeeScript.compile "f(x) ->"
  f = (g) -> g()
  eq 5, f (x) -> 5

test "#1844: bound functions in nested comprehensions causing empty var statements", ->
  a = ((=>) for a in [0] for b in [0])
  eq 1, a.length

test "#1859: inline function bodies shouldn't modify prior postfix ifs", ->
  list = [1, 2, 3]
  ok true if list.some (x) -> x is 2

test "#2258: allow whitespace-style parameter lists in function definitions", ->
  func = (
    a, b, c
  ) -> c
  eq func(1, 2, 3), 3

  func = (
    a
    b
    c
  ) -> b
  eq func(1, 2, 3), 2

test "#2621: fancy destructuring in parameter lists", ->
  func = ({ prop1: { key1 }, prop2: { key2, key3: [a, b, c] } }) ->
    eq(key2, 'key2')
    eq(a, 'a')

  func({prop1: {key1: 'key1'}, prop2: {key2: 'key2', key3: ['a', 'b', 'c']}})

test "#1435 Indented property access", ->
  rec = -> rec: rec

  eq 1, do ->
    rec()
      .rec ->
        rec()
          .rec ->
            rec.rec()
          .rec()
    1

test "#1038 Optimize trailing return statements", ->
  compile = (code) -> CoffeeScript.compile(code, bare: yes).trim().replace(/\s+/g, " ")

  eq "(function() {});",                 compile("->")
  eq "(function() {});",                 compile("-> return")
  eq "(function() { return void 0; });", compile("-> undefined")
  eq "(function() { return void 0; });", compile("-> return undefined")
  eq "(function() { foo(); });",         compile("""
                                                 ->
                                                   foo()
                                                   return
                                                 """)
# Helpers
# -------

# pull the helpers from `CoffeeScript.helpers` into local variables
{starts, ends, repeat, compact, count, merge, extend, flatten, del, last, baseFileName} = CoffeeScript.helpers


# `starts`

test "the `starts` helper tests if a string starts with another string", ->
  ok     starts('01234', '012')
  ok not starts('01234', '123')

test "the `starts` helper can take an optional offset", ->
  ok     starts('01234', '34', 3)
  ok not starts('01234', '01', 1)


# `ends`

test "the `ends` helper tests if a string ends with another string", ->
  ok     ends('01234', '234')
  ok not ends('01234', '012')

test "the `ends` helper can take an optional offset", ->
  ok     ends('01234', '012', 2)
  ok not ends('01234', '234', 6)


# `repeat`

test "the `repeat` helper concatenates a given number of times", ->
  eq 'asdasdasd', repeat('asd', 3)

test "`repeat`ing a string 0 times always returns the empty string", ->
  eq '', repeat('whatever', 0)


# `compact`

test "the `compact` helper removes falsey values from an array, preserves truthy ones", ->
  allValues = [1, 0, false, obj={}, [], '', ' ', -1, null, undefined, true]
  truthyValues = [1, obj, [], ' ', -1, true]
  arrayEq truthyValues, compact(allValues)


# `count`

test "the `count` helper counts the number of occurances of a string in another string", ->
  eq 1/0, count('abc', '')
  eq 0, count('abc', 'z')
  eq 1, count('abc', 'a')
  eq 1, count('abc', 'b')
  eq 2, count('abcdc', 'c')
  eq 2, count('abcdabcd','abc')


# `merge`

test "the `merge` helper makes a new object with all properties of the objects given as its arguments", ->
  ary = [0, 1, 2, 3, 4]
  obj = {}
  merged = merge obj, ary
  ok merged isnt obj
  ok merged isnt ary
  for own key, val of ary
    eq val, merged[key]


# `extend`

test "the `extend` helper performs a shallow copy", ->
  ary = [0, 1, 2, 3]
  obj = {}
  # should return the object being extended
  eq obj, extend(obj, ary)
  # should copy the other object's properties as well (obviously)
  eq 2, obj[2]


# `flatten`

test "the `flatten` helper flattens an array", ->
  success = yes
  (success and= typeof n is 'number') for n in flatten [0, [[[1]], 2], 3, [4]]
  ok success


# `del`

test "the `del` helper deletes a property from an object and returns the deleted value", ->
  obj = [0, 1, 2]
  eq 1, del(obj, 1)
  ok 1 not of obj


# `last`

test "the `last` helper returns the last item of an array-like object", ->
  ary = [0, 1, 2, 3, 4]
  eq 4, last(ary)

test "the `last` helper allows one to specify an optional offset", ->
  ary = [0, 1, 2, 3, 4]
  eq 2, last(ary, 2)

# `baseFileName`

test "the `baseFileName` helper returns the file name to write to", ->
  ext = '.js'
  sourceToCompiled =
    '.coffee': ext
    'a.coffee': 'a' + ext
    'b.coffee': 'b' + ext
    'coffee.coffee': 'coffee' + ext

    '.litcoffee': ext
    'a.litcoffee': 'a' + ext
    'b.litcoffee': 'b' + ext
    'coffee.litcoffee': 'coffee' + ext

    '.lit': ext
    'a.lit': 'a' + ext
    'b.lit': 'b' + ext
    'coffee.lit': 'coffee' + ext

    '.coffee.md': ext
    'a.coffee.md': 'a' + ext
    'b.coffee.md': 'b' + ext
    'coffee.coffee.md': 'coffee' + ext

  for sourceFileName, expectedFileName of sourceToCompiled
    name = baseFileName sourceFileName, yes
    filename = name + ext
    eq filename, expectedFileName
# Importing
# ---------

unless window? or testingBrowser?
  test "coffeescript modules can be imported and executed", ->

    magicKey = __filename
    magicValue = 0xFFFF

    if global[magicKey]?
      if exports?
        local = magicValue
        exports.method = -> local
    else
      global[magicKey] = {}
      if require?.extensions?
        ok require(__filename).method() is magicValue
      delete global[magicKey]

  test "javascript modules can be imported", ->
    magicVal = 1
    for module in 'import.js import2 .import2 import.extension.js import.unknownextension .coffee .coffee.md'.split ' '
      ok require("./importing/#{module}").value?() is magicVal, module

  test "coffeescript modules can be imported", ->
    magicVal = 2
    for module in '.import.coffee import.coffee import.extension.coffee'.split ' '
      ok require("./importing/#{module}").value?() is magicVal, module

  test "literate coffeescript modules can be imported", ->
    magicVal = 3
    # Leading space intentional to check for index.coffee.md
    for module in ' .import.coffee.md import.coffee.md import.litcoffee import.extension.coffee.md'.split ' '
      ok require("./importing/#{module}").value?() is magicVal, module
# Interpolation
# -------------

# * String Interpolation
# * Regular Expression Interpolation

# String Interpolation

# TODO: refactor string interpolation tests

eq 'multiline nested "interpolations" work', """multiline #{
  "nested #{
    ok true
    "\"interpolations\""
  }"
} work"""

# Issue #923: Tricky interpolation.
eq "#{ "{" }", "{"
eq "#{ '#{}}' } }", '#{}} }'
eq "#{"'#{ ({a: "b#{1}"}['a']) }'"}", "'b1'"

# Issue #1150: String interpolation regression
eq "#{'"/'}",                '"/'
eq "#{"/'"}",                "/'"
eq "#{/'"/}",                '/\'"/'
eq "#{"'/" + '/"' + /"'/}",  '\'//"/"\'/'
eq "#{"'/"}#{'/"'}#{/"'/}",  '\'//"/"\'/'
eq "#{6 / 2}",               '3'
eq "#{6 / 2}#{6 / 2}",       '33' # parsed as division
eq "#{6 + /2}#{6/ + 2}",     '6/2}#{6/2' # parsed as a regex
eq "#{6/2}
    #{6/2}",                 '3 3' # newline cannot be part of a regex, so it's division
eq "#{/// "'/'"/" ///}",     '/"\'\\/\'"\\/"/' # heregex, stuffed with spicy characters
eq "#{/\\'/}",               "/\\\\'/"

hello = 'Hello'
world = 'World'
ok '#{hello} #{world}!' is '#{hello} #{world}!'
ok "#{hello} #{world}!" is 'Hello World!'
ok "[#{hello}#{world}]" is '[HelloWorld]'
ok "#{hello}##{world}" is 'Hello#World'
ok "Hello #{ 1 + 2 } World" is 'Hello 3 World'
ok "#{hello} #{ 1 + 2 } #{world}" is "Hello 3 World"

[s, t, r, i, n, g] = ['s', 't', 'r', 'i', 'n', 'g']
ok "#{s}#{t}#{r}#{i}#{n}#{g}" is 'string'
ok "\#{s}\#{t}\#{r}\#{i}\#{n}\#{g}" is '#{s}#{t}#{r}#{i}#{n}#{g}'
ok "\#{string}" is '#{string}'

ok "\#{Escaping} first" is '#{Escaping} first'
ok "Escaping \#{in} middle" is 'Escaping #{in} middle'
ok "Escaping \#{last}" is 'Escaping #{last}'

ok "##" is '##'
ok "#{}" is ''
ok "#{}A#{} #{} #{}B#{}" is 'A  B'
ok "\\\#{}" is '\\#{}'

ok "I won ##{20} last night." is 'I won #20 last night.'
ok "I won ##{'#20'} last night." is 'I won ##20 last night.'

ok "#{hello + world}" is 'HelloWorld'
ok "#{hello + ' ' + world + '!'}" is 'Hello World!'

list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
ok "values: #{list.join(', ')}, length: #{list.length}." is 'values: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, length: 10.'
ok "values: #{list.join ' '}" is 'values: 0 1 2 3 4 5 6 7 8 9'

obj = {
  name: 'Joe'
  hi: -> "Hello #{@name}."
  cya: -> "Hello #{@name}.".replace('Hello','Goodbye')
}
ok obj.hi() is "Hello Joe."
ok obj.cya() is "Goodbye Joe."

ok "With #{"quotes"}" is 'With quotes'
ok 'With #{"quotes"}' is 'With #{"quotes"}'

ok "Where is #{obj["name"] + '?'}" is 'Where is Joe?'

ok "Where is #{"the nested #{obj["name"]}"}?" is 'Where is the nested Joe?'
ok "Hello #{world ? "#{hello}"}" is 'Hello World'

ok "Hello #{"#{"#{obj["name"]}" + '!'}"}" is 'Hello Joe!'

a = """
    Hello #{ "Joe" }
    """
ok a is "Hello Joe"

a = 1
b = 2
c = 3
ok "#{a}#{b}#{c}" is '123'

result = null
stash = (str) -> result = str
stash "a #{ ('aa').replace /a/g, 'b' } c"
ok result is 'a bb c'

foo = "hello"
ok "#{foo.replace("\"", "")}" is 'hello'

val = 10
a = """
    basic heredoc #{val}
    on two lines
    """
b = '''
    basic heredoc #{val}
    on two lines
    '''
ok a is "basic heredoc 10\non two lines"
ok b is "basic heredoc \#{val}\non two lines"

eq 'multiline nested "interpolations" work', """multiline #{
  "nested #{(->
    ok yes
    "\"interpolations\""
  )()}"
} work"""


# Regular Expression Interpolation

# TODO: improve heregex interpolation tests

test "heregex interpolation", ->
  eq /\\#{}\\\"/ + '', ///
   #{
     "#{ '\\' }" # normal comment
   }
   # regex comment
   \#{}
   \\ \"
  /// + ''
# Javascript Literals
# -------------------

# TODO: refactor javascript literal tests
# TODO: add indexing and method invocation tests: `[1]`[0] is 1, `function(){}`.call()

eq '\\`', `
  // Inline JS
  "\\\`"
`
testScript = '''
if true
  x = 6
  console.log "A console #{x + 7} log"

foo = "bar"
z = /// ^ (a#{foo}) ///

x = () ->
    try
        console.log "foo"
    catch err
        # Rewriter will generate explicit indentation here.

    return null
'''

test "Verify location of generated tokens", ->
  tokens = CoffeeScript.tokens "a = 79"

  eq tokens.length, 4

  aToken = tokens[0]
  eq aToken[2].first_line, 0
  eq aToken[2].first_column, 0
  eq aToken[2].last_line, 0
  eq aToken[2].last_column, 0

  equalsToken = tokens[1]
  eq equalsToken[2].first_line, 0
  eq equalsToken[2].first_column, 2
  eq equalsToken[2].last_line, 0
  eq equalsToken[2].last_column, 2

  numberToken = tokens[2]
  eq numberToken[2].first_line, 0
  eq numberToken[2].first_column, 4
  eq numberToken[2].last_line, 0
  eq numberToken[2].last_column, 5

test "Verify location of generated tokens (with indented first line)", ->
  tokens = CoffeeScript.tokens "  a = 83"

  eq tokens.length, 4
  [aToken, equalsToken, numberToken] = tokens

  eq aToken[2].first_line, 0
  eq aToken[2].first_column, 2
  eq aToken[2].last_line, 0
  eq aToken[2].last_column, 2

  eq equalsToken[2].first_line, 0
  eq equalsToken[2].first_column, 4
  eq equalsToken[2].last_line, 0
  eq equalsToken[2].last_column, 4

  eq numberToken[2].first_line, 0
  eq numberToken[2].first_column, 6
  eq numberToken[2].last_line, 0
  eq numberToken[2].last_column, 7

test "Verify locations in string interpolation", ->
  tokens = CoffeeScript.tokens '"a#{b}c"'

  eq tokens.length, 8
  [openParen, a, firstPlus, b, secondPlus, c, closeParen] = tokens

  eq a[2].first_line, 0
  eq a[2].first_column, 1
  eq a[2].last_line, 0
  eq a[2].last_column, 1

  eq b[2].first_line, 0
  eq b[2].first_column, 4
  eq b[2].last_line, 0
  eq b[2].last_column, 4

  eq c[2].first_line, 0
  eq c[2].first_column, 6
  eq c[2].last_line, 0
  eq c[2].last_column, 6

test "Verify all tokens get a location", ->
  doesNotThrow ->
    tokens = CoffeeScript.tokens testScript
    for token in tokens
        ok !!token[2]
# Number Literals
# ---------------

# * Decimal Integer Literals
# * Octal Integer Literals
# * Hexadecimal Integer Literals
# * Scientific Notation Integer Literals
# * Scientific Notation Non-Integer Literals
# * Non-Integer Literals
# * Binary Integer Literals


# Binary Integer Literals
# Binary notation is understood as would be decimal notation.

test "Parser recognises binary numbers", ->
  eq 4, 0b100

# Decimal Integer Literals

test "call methods directly on numbers", ->
  eq 4, 4.valueOf()
  eq '11', 4.toString 3

eq -1, 3 -4

#764: Numbers should be indexable
eq Number::toString, 42['toString']

eq Number::toString, 42.toString


# Non-Integer Literals

# Decimal number literals.
value = .25 + .75
ok value is 1
value = 0.0 + -.25 - -.75 + 0.0
ok value is 0.5

#764: Numbers should be indexable
eq Number::toString,   4['toString']
eq Number::toString, 4.2['toString']
eq Number::toString, .42['toString']
eq Number::toString, (4)['toString']

eq Number::toString,   4.toString
eq Number::toString, 4.2.toString
eq Number::toString, .42.toString
eq Number::toString, (4).toString

test '#1168: leading floating point suppresses newline', ->
  eq 1, do ->
    1
    .5 + 0.5

test "Python-style octal literal notation '0o777'", ->
  eq 511, 0o777
  eq 1, 0o1
  eq 1, 0o00001
  eq parseInt('0777', 8), 0o777
  eq '777', 0o777.toString 8
  eq 4, 0o4.valueOf()
  eq Number::toString, 0o777['toString']
  eq Number::toString, 0o777.toString

test "#2060: Disallow uppercase radix prefixes and exponential notation", ->
  for char in ['b', 'o', 'x', 'e']
    program = "0#{char}0"
    doesNotThrow -> CoffeeScript.compile program, bare: yes
    throws -> CoffeeScript.compile program.toUpperCase(), bare: yes

test "#2224: hex literals with 0b or B or E", ->
  eq 176, 0x0b0
  eq 177, 0x0B1
  eq 225, 0xE1
# Object Literals
# ---------------

# TODO: refactor object literal tests
# TODO: add indexing and method invocation tests: {a}['a'] is a, {a}.a()

trailingComma = {k1: "v1", k2: 4, k3: (-> true),}
ok trailingComma.k3() and (trailingComma.k2 is 4) and (trailingComma.k1 is "v1")

ok {a: (num) -> num is 10 }.a 10

moe = {
  name:  'Moe'
  greet: (salutation) ->
    salutation + " " + @name
  hello: ->
    @['greet'] "Hello"
  10: 'number'
}
ok moe.hello() is "Hello Moe"
ok moe[10] is 'number'
moe.hello = ->
  this['greet'] "Hello"
ok moe.hello() is 'Hello Moe'

obj = {
  is:     -> yes,
  'not':  -> no,
}
ok obj.is()
ok not obj.not()

### Top-level object literal... ###
obj: 1
### ...doesn't break things. ###

# Object literals should be able to include keywords.
obj = {class: 'höt'}
obj.function = 'dog'
ok obj.class + obj.function is 'hötdog'

# Implicit objects as part of chained calls.
pluck = (x) -> x.a
eq 100, pluck pluck pluck a: a: a: 100


test "YAML-style object literals", ->
  obj =
    a: 1
    b: 2
  eq 1, obj.a
  eq 2, obj.b

  config =
    development:
      server: 'localhost'
      timeout: 10

    production:
      server: 'dreamboat'
      timeout: 1000

  ok config.development.server  is 'localhost'
  ok config.production.server   is 'dreamboat'
  ok config.development.timeout is 10
  ok config.production.timeout  is 1000

obj =
  a: 1,
  b: 2,
ok obj.a is 1
ok obj.b is 2

# Implicit objects nesting.
obj =
  options:
    value: yes
  fn: ->
    {}
    null
ok obj.options.value is yes
ok obj.fn() is null

# Implicit objects with wacky indentation:
obj =
  'reverse': (obj) ->
    Array.prototype.reverse.call obj
  abc: ->
    @reverse(
      @reverse @reverse ['a', 'b', 'c'].reverse()
    )
  one: [1, 2,
    a: 'b'
  3, 4]
  red:
    orange:
          yellow:
                  green: 'blue'
    indigo: 'violet'
  misdent: [[],
  [],
                  [],
      []]
ok obj.abc().join(' ') is 'a b c'
ok obj.one.length is 5
ok obj.one[4] is 4
ok obj.one[2].a is 'b'
ok (key for key of obj.red).length is 2
ok obj.red.orange.yellow.green is 'blue'
ok obj.red.indigo is 'violet'
ok obj.misdent.toString() is ',,,'

#542: Objects leading expression statement should be parenthesized.
{f: -> ok yes }.f() + 1

# String-keyed objects shouldn't suppress newlines.
one =
  '>!': 3
six: -> 10
ok not one.six

# Shorthand objects with property references.
obj =
  ### comment one ###
  ### comment two ###
  one: 1
  two: 2
  object: -> {@one, @two}
  list:   -> [@one, @two]
result = obj.object()
eq result.one, 1
eq result.two, 2
eq result.two, obj.list()[1]

third = (a, b, c) -> c
obj =
  one: 'one'
  two: third 'one', 'two', 'three'
ok obj.one is 'one'
ok obj.two is 'three'

test "invoking functions with implicit object literals", ->
  generateGetter = (prop) -> (obj) -> obj[prop]
  getA = generateGetter 'a'
  getArgs = -> arguments
  a = b = 30

  result = getA
    a: 10
  eq 10, result

  result = getA
    "a": 20
  eq 20, result

  result = getA a,
    b:1
  eq undefined, result

  result = getA b:1,
  a:43
  eq 43, result

  result = getA b:1,
    a:62
  eq undefined, result

  result = getA
    b:1
    a
  eq undefined, result

  result = getA
    a:
      b:2
    b:1
  eq 2, result.b

  result = getArgs
    a:1
    b
    c:1
  ok result.length is 3
  ok result[2].c is 1

  result = getA b: 13, a: 42, 2
  eq 42, result

  result = getArgs a:1, (1 + 1)
  ok result[1] is 2

  result = getArgs a:1, b
  ok result.length is 2
  ok result[1] is 30

  result = getArgs a:1, b, b:1, a
  ok result.length is 4
  ok result[2].b is 1

  throws -> CoffeeScript.compile "a = b:1, c"

test "some weird indentation in YAML-style object literals", ->
  two = (a, b) -> b
  obj = then two 1,
    1: 1
    a:
      b: ->
        fn c,
          d: e
    f: 1
  eq 1, obj[1]

test "#1274: `{} = a()` compiles to `false` instead of `a()`", ->
  a = false
  fn = -> a = true
  {} = fn()
  ok a

test "#1436: `for` etc. work as normal property names", ->
  obj = {}
  eq no, obj.hasOwnProperty 'for'
  obj.for = 'foo' of obj
  eq yes, obj.hasOwnProperty 'for'

test "#2706, Un-bracketed object as argument causes inconsistent behavior", ->
  foo = (x, y) -> y
  bar = baz: yes

  eq yes, foo x: 1, bar.baz

test "#2608, Allow inline objects in arguments to be followed by more arguments", ->
  foo = (x, y) -> y

  eq yes, foo x: 1, y: 2, yes

test "#2308, a: b = c:1", ->
  foo = a: b = c: yes
  eq b.c, yes
  eq foo.a.c, yes

test "#2317, a: b c: 1", ->
  foo = (x) -> x
  bar = a: foo c: yes
  eq bar.a.c, yes

test "#1896, a: func b, {c: d}", ->
  first = (x) -> x
  second = (x, y) -> y
  third = (x, y, z) -> z

  one = 1
  two = 2
  three = 3
  four = 4

  foo = a: second one, {c: two}
  eq foo.a.c, two

  bar = a: second one, c: two
  eq bar.a.c, two

  baz = a: second one, {c: two}, e: first first h: three
  eq baz.a.c, two

  qux = a: third one, {c: two}, e: first first h: three
  eq qux.a.e.h, three

  quux = a: third one, {c: two}, e: first(three), h: four
  eq quux.a.e, three
  eq quux.a.h, four

  corge = a: third one, {c: two}, e: second three, h: four
  eq corge.a.e.h, four

test "Implicit objects, functions and arrays", ->
  first  = (x) -> x
  second = (x, y) -> y

  foo = [
    1
    one: 1
    two: 2
    three: 3
    more:
      four: 4
      five: 5, six: 6
    2, 3, 4
    5]
  eq foo[2], 2
  eq foo[1].more.six, 6

  bar = [
    1
    first first first second 1,
      one: 1, twoandthree: twoandthree: two: 2, three: 3
      2,
    2
    one: 1
    two: 2
    three: first second ->
      no
    , ->
      3
    3
    4]
  eq bar[2], 2
  eq bar[1].twoandthree.twoandthree.two, 2
  eq bar[3].three(), 3
  eq bar[4], 3

test "#2549, Brace-less Object Literal as a Second Operand on a New Line", ->
  foo = no or
    one: 1
    two: 2
    three: 3
  eq foo.one, 1

  bar = yes and one: 1
  eq bar.one, 1

  baz = null ?
    one: 1
    two: 2
  eq baz.two, 2

test "#2757, Nested", ->
  foo =
    bar:
      one: 1,
  eq foo.bar.one, 1

  baz =
    qux:
      one: 1,
    corge:
      two: 2,
      three: three: three: 3,
    xyzzy:
      thud:
        four:
          four: 4,
      five: 5,

  eq baz.qux.one, 1
  eq baz.corge.three.three.three, 3
  eq baz.xyzzy.thud.four.four, 4
  eq baz.xyzzy.five, 5

test "#1865, syntax regression 1.1.3", ->
  foo = (x, y) -> y

  bar = a: foo (->),
    c: yes
  eq bar.a.c, yes

  baz = a: foo (->), c: yes
  eq baz.a.c, yes


test "#1322: implicit call against implicit object with block comments", ->
  ((obj, arg) ->
    eq obj.x * obj.y, 6
    ok not arg
  )
    ###
    x
    ###
    x: 2
    ### y ###
    y: 3

test "#1513: Top level bare objs need to be wrapped in parens for unary and existence ops", ->
  doesNotThrow -> CoffeeScript.run "{}?", bare: true
  doesNotThrow -> CoffeeScript.run "{}.a++", bare: true

test "#1871: Special case for IMPLICIT_END in the middle of an implicit object", ->
  result = 'result'
  ident = (x) -> x

  result = ident one: 1 if false

  eq result, 'result'

  result = ident
    one: 1
    two: 2 for i in [1..3]

  eq result.two.join(' '), '2 2 2'

test "#1871: implicit object closed by IMPLICIT_END in implicit returns", ->
  ob = do ->
    a: 1 if no
  eq ob, undefined

  # instead these return an object
  func = ->
    key:
      i for i in [1, 2, 3]

  eq func().key.join(' '), '1 2 3'

  func = ->
    key: (i for i in [1, 2, 3])

  eq func().key.join(' '), '1 2 3'

test "#1961, #1974, regression with compound assigning to an implicit object", ->

  obj = null

  obj ?=
    one: 1
    two: 2

  eq obj.two, 2

  obj = null

  obj or=
    three: 3
    four: 4

  eq obj.four, 4

test "#2207: Immediate implicit closes don't close implicit objects", ->
  func = ->
    key: for i in [1, 2, 3] then i

  eq func().key.join(' '), '1 2 3'

test "#3216: For loop declaration as a value of an implicit object", ->
  test = [0..2]
  ob =
    a: for v, i in test then i
    b: for v, i in test then i
    c: for v in test by 1 then v
    d: for v in test when true then v
  arrayEq ob.a, test
  arrayEq ob.b, test
  arrayEq ob.c, test
  arrayEq ob.d, test

test 'inline implicit object literals within multiline implicit object literals', ->
  x =
    a: aa: 0
    b: 0
  eq 0, x.b
  eq 0, x.a.aa
# Operators
# ---------

# * Operators
# * Existential Operator (Binary)
# * Existential Operator (Unary)
# * Aliased Operators
# * [not] in/of
# * Chained Comparison

test "binary (2-ary) math operators do not require spaces", ->
  a = 1
  b = -1
  eq +1, a*-b
  eq -1, a*+b
  eq +1, a/-b
  eq -1, a/+b

test "operators should respect new lines as spaced", ->
  a = 123 +
  456
  eq 579, a

  b = "1#{2}3" +
  "456"
  eq '123456', b

test "multiple operators should space themselves", ->
  eq (+ +1), (- -1)

test "compound operators on successive lines", ->
  a = 1
  a +=
  1
  eq a, 2

test "bitwise operators", ->
  eq  2, (10 &   3)
  eq 11, (10 |   3)
  eq  9, (10 ^   3)
  eq 80, (10 <<  3)
  eq  1, (10 >>  3)
  eq  1, (10 >>> 3)
  num = 10; eq  2, (num &=   3)
  num = 10; eq 11, (num |=   3)
  num = 10; eq  9, (num ^=   3)
  num = 10; eq 80, (num <<=  3)
  num = 10; eq  1, (num >>=  3)
  num = 10; eq  1, (num >>>= 3)

test "`instanceof`", ->
  ok new String instanceof String
  ok new Boolean instanceof Boolean
  # `instanceof` supports negation by prefixing the operator with `not`
  ok new Number not instanceof String
  ok new Array not instanceof Boolean

test "use `::` operator on keywords `this` and `@`", ->
  nonce = {}
  obj =
    withAt:   -> @::prop
    withThis: -> this::prop
  obj.prototype = prop: nonce
  eq nonce, obj.withAt()
  eq nonce, obj.withThis()


# Existential Operator (Binary)

test "binary existential operator", ->
  nonce = {}

  b = a ? nonce
  eq nonce, b

  a = null
  b = undefined
  b = a ? nonce
  eq nonce, b

  a = false
  b = a ? nonce
  eq false, b

  a = 0
  b = a ? nonce
  eq 0, b

test "binary existential operator conditionally evaluates second operand", ->
  i = 1
  func = -> i -= 1
  result = func() ? func()
  eq result, 0

test "binary existential operator with negative number", ->
  a = null ? - 1
  eq -1, a


# Existential Operator (Unary)

test "postfix existential operator", ->
  ok (if nonexistent? then false else true)
  defined = true
  ok defined?
  defined = false
  ok defined?

test "postfix existential operator only evaluates its operand once", ->
  semaphore = 0
  fn = ->
    ok false if semaphore
    ++semaphore
  ok(if fn()? then true else false)

test "negated postfix existential operator", ->
  ok !nothing?.value

test "postfix existential operator on expressions", ->
  eq true, (1 or 0)?, true


# `is`,`isnt`,`==`,`!=`

test "`==` and `is` should be interchangeable", ->
  a = b = 1
  ok a is 1 and b == 1
  ok a == b
  ok a is b

test "`!=` and `isnt` should be interchangeable", ->
  a = 0
  b = 1
  ok a isnt 1 and b != 0
  ok a != b
  ok a isnt b


# [not] in/of

# - `in` should check if an array contains a value using `indexOf`
# - `of` should check if a property is defined on an object using `in`
test "in, of", ->
  arr = [1]
  ok 0 of arr
  ok 1 in arr
  # prefixing `not` to `in and `of` should negate them
  ok 1 not of arr
  ok 0 not in arr

test "`in` should be able to operate on an array literal", ->
  ok 2 in [0, 1, 2, 3]
  ok 4 not in [0, 1, 2, 3]
  arr = [0, 1, 2, 3]
  ok 2 in arr
  ok 4 not in arr
  # should cache the value used to test the array
  arr = [0]
  val = 0
  ok val++ in arr
  ok val++ not in arr
  val = 0
  ok val++ of arr
  ok val++ not of arr

test "`of` and `in` should be able to operate on instance variables", ->
  obj = {
    list: [2,3]
    in_list: (value) -> value in @list
    not_in_list: (value) -> value not in @list
    of_list: (value) -> value of @list
    not_of_list: (value) -> value not of @list
  }
  ok obj.in_list 3
  ok obj.not_in_list 1
  ok obj.of_list 0
  ok obj.not_of_list 2

test "#???: `in` with cache and `__indexOf` should work in argument lists", ->
  eq 1, [Object() in Array()].length

test "#737: `in` should have higher precedence than logical operators", ->
  eq 1, 1 in [1] and 1

test "#768: `in` should preserve evaluation order", ->
  share = 0
  a = -> share++ if share is 0
  b = -> share++ if share is 1
  c = -> share++ if share is 2
  ok a() not in [b(),c()]
  eq 3, share

test "#1099: empty array after `in` should compile to `false`", ->
  eq 1, [5 in []].length
  eq false, do -> return 0 in []

test "#1354: optimized `in` checks should not happen when splats are present", ->
  a = [6, 9]
  eq 9 in [3, a...], true

test "#1100: precedence in or-test compilation of `in`", ->
  ok 0 in [1 and 0]
  ok 0 in [1, 1 and 0]
  ok not (0 in [1, 0 or 1])

test "#1630: `in` should check `hasOwnProperty`", ->
  ok undefined not in length: 1

test "#1714: lexer bug with raw range `for` followed by `in`", ->
  0 for [1..2]
  ok not ('a' in ['b'])

  0 for [1..2]; ok not ('a' in ['b'])

  0 for [1..10] # comment ending
  ok not ('a' in ['b'])

test "#1099: statically determined `not in []` reporting incorrect result", ->
  ok 0 not in []

test "#1099: make sure expression tested gets evaluted when array is empty", ->
  a = 0
  (do -> a = 1) in []
  eq a, 1

# Chained Comparison

test "chainable operators", ->
  ok 100 > 10 > 1 > 0 > -1
  ok -1 < 0 < 1 < 10 < 100

test "`is` and `isnt` may be chained", ->
  ok true is not false is true is not false
  ok 0 is 0 isnt 1 is 1

test "different comparison operators (`>`,`<`,`is`,etc.) may be combined", ->
  ok 1 < 2 > 1
  ok 10 < 20 > 2+3 is 5

test "some chainable operators can be negated by `unless`", ->
  ok (true unless 0==10!=100)

test "operator precedence: `|` lower than `<`", ->
  eq 1, 1 | 2 < 3 < 4

test "preserve references", ->
  a = b = c = 1
  # `a == b <= c` should become `a === b && b <= c`
  # (this test does not seem to test for this)
  ok a == b <= c

test "chained operations should evaluate each value only once", ->
  a = 0
  ok 1 > a++ < 1

test "#891: incorrect inversion of chained comparisons", ->
  ok (true unless 0 > 1 > 2)
  ok (true unless (NaN = 0/0) < 0/0 < NaN)

test "#1234: Applying a splat to :: applies the splat to the wrong object", ->
  nonce = {}
  class C
    method: -> @nonce
    nonce: nonce

  arr = []
  eq nonce, C::method arr... # should be applied to `C::`

test "#1102: String literal prevents line continuation", ->
  eq "': '", '' +
     "': '"

test "#1703, ---x is invalid JS", ->
  x = 2
  eq (- --x), -1

test "Regression with implicit calls against an indented assignment", ->
  eq 1, a =
    1

  eq a, 1

test "#2155 ... conditional assignment to a closure", ->
  x = null
  func = -> x ?= (-> if true then 'hi')
  func()
  eq x(), 'hi'

test "#2197: Existential existential double trouble", ->
  counter = 0
  func = -> counter++
  func()? ? 100
  eq counter, 1

test "#2567: Optimization of negated existential produces correct result", ->
  a = 1
  ok !(!a?)
  ok !b?

test "#2508: Existential access of the prototype", ->
  eq NonExistent?::nothing, undefined
  ok Object?::toString

test "power operator", ->
  eq 27, 3 ** 3

test "power operator has higher precedence than other maths operators", ->
  eq 55, 1 + 3 ** 3 * 2
  eq -4, -2 ** 2
  eq false, !2 ** 2
  eq 0, (!2) ** 2
  eq -2, ~1 ** 5

test "power operator is right associative", ->
  eq 2, 2 ** 1 ** 3

test "power operator compound assignment", ->
  a = 2
  a **= 3
  eq 8, a

test "floor division operator", ->
  eq 2, 7 // 3
  eq -3, -7 // 3
  eq NaN, 0 // 0

test "floor division operator compound assignment", ->
  a = 7
  a //= 2
  eq 3, a

test "modulo operator", ->
  check = (a, b, expected) ->
    eq expected, a %% b, "expected #{a} %%%% #{b} to be #{expected}"
  check 0, 1, 0
  check 0, -1, -0
  check 1, 0, NaN
  check 1, 2, 1
  check 1, -2, -1
  check 1, 3, 1
  check 2, 3, 2
  check 3, 3, 0
  check 4, 3, 1
  check -1, 3, 2
  check -2, 3, 1
  check -3, 3, 0
  check -4, 3, 2
  check 5.5, 2.5, 0.5
  check -5.5, 2.5, 2.0

test "modulo operator compound assignment", ->
  a = -2
  a %%= 5
  eq 3, a

test "modulo operator converts arguments to numbers", ->
  eq 1, 1 %% '42'
  eq 1, '1' %% 42
  eq 1, '1' %% '42'

test "#3361: Modulo operator coerces right operand once", ->
  count = 0
  res = 42 %% valueOf: -> count += 1
  eq 1, count
  eq 0, res

test "#3363: Modulo operator coercing order", ->
  count = 2
  a = valueOf: -> count *= 2
  b = valueOf: -> count += 1
  eq 4, a %% b
  eq 5, count
# Option Parser
# -------------

# TODO: refactor option parser tests

# Ensure that the OptionParser handles arguments correctly.
return unless require?
{OptionParser} = require './../lib/coffee-script/optparse'

opt = new OptionParser [
  ['-r', '--required [DIR]',  'desc required']
  ['-o', '--optional',        'desc optional']
  ['-l', '--list [FILES*]',   'desc list']
]

test "basic arguments", ->
  args = ['one', 'two', 'three', '-r', 'dir']
  result = opt.parse args
  arrayEq args, result.arguments
  eq undefined, result.required

test "boolean and parameterised options", ->
  result = opt.parse ['--optional', '-r', 'folder', 'one', 'two']
  ok result.optional
  eq 'folder', result.required
  arrayEq ['one', 'two'], result.arguments

test "list options", ->
  result = opt.parse ['-l', 'one.txt', '-l', 'two.txt', 'three']
  arrayEq ['one.txt', 'two.txt'], result.list
  arrayEq ['three'], result.arguments

test "-- and interesting combinations", ->
  result = opt.parse ['-o','-r','a','-r','b','-o','--','-a','b','--c','d']
  arrayEq ['-a', 'b', '--c', 'd'], result.arguments
  ok result.optional
  eq 'b', result.required

  args = ['--','-o','a','-r','c','-o','--','-a','arg0','-b','arg1']
  result = opt.parse args
  eq undefined, result.optional
  eq undefined, result.required
  arrayEq args[1..], result.arguments
# Range Literals
# --------------

# TODO: add indexing and method invocation tests: [1..4][0] is 1, [0...3].toString()

# shared array
shared = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

test "basic inclusive ranges", ->
  arrayEq [1, 2, 3] , [1..3]
  arrayEq [0, 1, 2] , [0..2]
  arrayEq [0, 1]    , [0..1]
  arrayEq [0]       , [0..0]
  arrayEq [-1]      , [-1..-1]
  arrayEq [-1, 0]   , [-1..0]
  arrayEq [-1, 0, 1], [-1..1]

test "basic exclusive ranges", ->
  arrayEq [1, 2, 3] , [1...4]
  arrayEq [0, 1, 2] , [0...3]
  arrayEq [0, 1]    , [0...2]
  arrayEq [0]       , [0...1]
  arrayEq [-1]      , [-1...0]
  arrayEq [-1, 0]   , [-1...1]
  arrayEq [-1, 0, 1], [-1...2]

  arrayEq [], [1...1]
  arrayEq [], [0...0]
  arrayEq [], [-1...-1]

test "downward ranges", ->
  arrayEq shared, [9..0].reverse()
  arrayEq [5, 4, 3, 2] , [5..2]
  arrayEq [2, 1, 0, -1], [2..-1]

  arrayEq [3, 2, 1]  , [3..1]
  arrayEq [2, 1, 0]  , [2..0]
  arrayEq [1, 0]     , [1..0]
  arrayEq [0]        , [0..0]
  arrayEq [-1]       , [-1..-1]
  arrayEq [0, -1]    , [0..-1]
  arrayEq [1, 0, -1] , [1..-1]
  arrayEq [0, -1, -2], [0..-2]

  arrayEq [4, 3, 2], [4...1]
  arrayEq [3, 2, 1], [3...0]
  arrayEq [2, 1]   , [2...0]
  arrayEq [1]      , [1...0]
  arrayEq []       , [0...0]
  arrayEq []       , [-1...-1]
  arrayEq [0]      , [0...-1]
  arrayEq [0, -1]  , [0...-2]
  arrayEq [1, 0]   , [1...-1]
  arrayEq [2, 1, 0], [2...-1]

test "ranges with variables as enpoints", ->
  [a, b] = [1, 3]
  arrayEq [1, 2, 3], [a..b]
  arrayEq [1, 2]   , [a...b]
  b = -2
  arrayEq [1, 0, -1, -2], [a..b]
  arrayEq [1, 0, -1]    , [a...b]

test "ranges with expressions as endpoints", ->
  [a, b] = [1, 3]
  arrayEq [2, 3, 4, 5, 6], [(a+1)..2*b]
  arrayEq [2, 3, 4, 5]   , [(a+1)...2*b]

test "large ranges are generated with looping constructs", ->
  down = [99..0]
  eq 100, (len = down.length)
  eq   0, down[len - 1]

  up = [0...100]
  eq 100, (len = up.length)
  eq  99, up[len - 1]

test "#1012 slices with arguments object", ->
  expected = [0..9]
  argsAtStart = (-> [arguments[0]..9]) 0
  arrayEq expected, argsAtStart
  argsAtEnd = (-> [0..arguments[0]]) 9
  arrayEq expected, argsAtEnd
  argsAtBoth = (-> [arguments[0]..arguments[1]]) 0, 9
  arrayEq expected, argsAtBoth

test "#1409: creating large ranges outside of a function body", ->
  CoffeeScript.eval '[0..100]'
# Regular Expression Literals
# ---------------------------

# TODO: add method invocation tests: /regex/.toString()

# * Regexen
# * Heregexen

test "basic regular expression literals", ->
  ok 'a'.match(/a/)
  ok 'a'.match /a/
  ok 'a'.match(/a/g)
  ok 'a'.match /a/g

test "division is not confused for a regular expression", ->
  eq 2, 4 / 2 / 1

  a = 4
  b = 2
  g = 1
  eq 2, a / b/g

  a = 10
  b = a /= 4 / 2
  eq a, 5

  obj = method: -> 2
  two = 2
  eq 2, (obj.method()/two + obj.method()/two)

  i = 1
  eq 2, (4)/2/i
  eq 1, i/i/i

test "#764: regular expressions should be indexable", ->
  eq /0/['source'], ///#{0}///['source']

test "#584: slashes are allowed unescaped in character classes", ->
  ok /^a\/[/]b$/.test 'a//b'

test "#1724: regular expressions beginning with `*`", ->
  throws -> CoffeeScript.compile '/*/'


# Heregexe(n|s)

test "a heregex will ignore whitespace and comments", ->
  eq /^I'm\x20+[a]\s+Heregex?\/\/\//gim + '', ///
    ^ I'm \x20+ [a] \s+
    Heregex? / // # or not
  ///gim + ''

test "an empty heregex will compile to an empty, non-capturing group", ->
  eq /(?:)/ + '', ///  /// + ''

test "#1724: regular expressions beginning with `*`", ->
  throws -> CoffeeScript.compile '/// * ///'
return if global.testingBrowser

fs = require 'fs'

# REPL
# ----
Stream = require 'stream'

class MockInputStream extends Stream
  constructor: ->
    @readable = true

  resume: ->

  emitLine: (val) ->
    @emit 'data', new Buffer("#{val}\n")

class MockOutputStream extends Stream
  constructor: ->
    @writable = true
    @written = []

  write: (data) ->
    #console.log 'output write', arguments
    @written.push data

  lastWrite: (fromEnd = -1) ->
    @written[@written.length - 1 + fromEnd].replace /\n$/, ''

# Create a dummy history file
historyFile = '.coffee_history_test'
fs.writeFileSync historyFile, '1 + 2\n'

testRepl = (desc, fn) ->
  input = new MockInputStream
  output = new MockOutputStream
  repl = Repl.start {input, output, historyFile}
  test desc, -> fn input, output, repl

ctrlV = { ctrl: true, name: 'v'}


testRepl 'reads history file', (input, output, repl) ->
  input.emitLine repl.rli.history[0]
  eq '3', output.lastWrite()

testRepl "starts with coffee prompt", (input, output) ->
  eq 'coffee> ', output.lastWrite(0)

testRepl "writes eval to output", (input, output) ->
  input.emitLine '1+1'
  eq '2', output.lastWrite()

testRepl "comments are ignored", (input, output) ->
  input.emitLine '1 + 1 #foo'
  eq '2', output.lastWrite()

testRepl "output in inspect mode", (input, output) ->
  input.emitLine '"1 + 1\\n"'
  eq "'1 + 1\\n'", output.lastWrite()

testRepl "variables are saved", (input, output) ->
  input.emitLine "foo = 'foo'"
  input.emitLine 'foobar = "#{foo}bar"'
  eq "'foobar'", output.lastWrite()

testRepl "empty command evaluates to undefined", (input, output) ->
  input.emitLine ''
  eq 'undefined', output.lastWrite()

testRepl "ctrl-v toggles multiline prompt", (input, output) ->
  input.emit 'keypress', null, ctrlV
  eq '------> ', output.lastWrite(0)
  input.emit 'keypress', null, ctrlV
  eq 'coffee> ', output.lastWrite(0)

testRepl "multiline continuation changes prompt", (input, output) ->
  input.emit 'keypress', null, ctrlV
  input.emitLine ''
  eq '....... ', output.lastWrite(0)

testRepl "evaluates multiline", (input, output) ->
  # Stubs. Could assert on their use.
  output.cursorTo = (pos) ->
  output.clearLine = ->

  input.emit 'keypress', null, ctrlV
  input.emitLine 'do ->'
  input.emitLine '  1 + 1'
  input.emit 'keypress', null, ctrlV
  eq '2', output.lastWrite()

testRepl "variables in scope are preserved", (input, output) ->
  input.emitLine 'a = 1'
  input.emitLine 'do -> a = 2'
  input.emitLine 'a'
  eq '2', output.lastWrite()

testRepl "existential assignment of previously declared variable", (input, output) ->
  input.emitLine 'a = null'
  input.emitLine 'a ?= 42'
  eq '42', output.lastWrite()

testRepl "keeps running after runtime error", (input, output) ->
  input.emitLine 'a = b'
  eq 0, output.lastWrite().indexOf 'ReferenceError: b is not defined'
  input.emitLine 'a'
  eq 'undefined', output.lastWrite()

process.on 'exit', ->
  fs.unlinkSync historyFile
# Scope
# -----

# * Variable Safety
# * Variable Shadowing
# * Auto-closure (`do`)
# * Global Scope Leaks

test "reference `arguments` inside of functions", ->
  sumOfArgs = ->
    sum = (a,b) -> a + b
    sum = 0
    sum += num for num in arguments
    sum
  eq 10, sumOfArgs(0, 1, 2, 3, 4)

test "assignment to an Object.prototype-named variable should not leak to outer scope", ->
  # FIXME: fails on IE
  (->
    constructor = 'word'
  )()
  ok constructor isnt 'word'

test "siblings of splat parameters shouldn't leak to surrounding scope", ->
  x = 10
  oops = (x, args...) ->
  oops(20, 1, 2, 3)
  eq x, 10

test "catch statements should introduce their argument to scope", ->
  try throw ''
  catch e
    do -> e = 5
    eq 5, e

test "loop variable should be accessible after for-of loop", ->
  d = (x for x of {1:'a',2:'b'})
  ok x in ['1','2']

test "loop variable should be accessible after for-in loop", ->
  d = (x for x in [1,2])
  eq x, 2

class Array then slice: fail # needs to be global
class Object then hasOwnProperty: fail
test "#1973: redefining Array/Object constructors shouldn't confuse __X helpers", ->
  arr = [1..4]
  arrayEq [3, 4], arr[2..]
  obj = {arr}
  for own k of obj
    eq arr, obj[k]

test "#2255: global leak with splatted @-params", ->
  ok not x?
  arrayEq [0], ((@x...) -> @x).call {}, 0
  ok not x?

test "#1183: super + fat arrows", ->
  dolater = (cb) -> cb()

  class A
  	constructor: ->
  		@_i = 0
  	foo : (cb) ->
  		dolater => 
  			@_i += 1 
  			cb()

  class B extends A
  	constructor : ->
  		super
  	foo : (cb) ->
  		dolater =>
  			dolater =>
  				@_i += 2
  				super cb
          
  b = new B
  b.foo => eq b._i, 3

test "#1183: super + wrap", ->
  class A
    m : -> 10
    
  class B extends A
    constructor : -> super
    
  B::m = -> r = try super()
  
  eq (new B).m(), 10

test "#1183: super + closures", ->
  class A
    constructor: ->
      @i = 10
    foo : -> @i
    
  class B extends A
    foo : ->
      ret = switch 1
        when 0 then 0
        when 1 then super()
      ret
  eq (new B).foo(), 10
 
test "#2331: bound super regression", ->
  class A
    @value = 'A'
    method: -> @constructor.value
    
  class B extends A
    method: => super
  
  eq (new B).method(), 'A'

test "#3259: leak with @-params within destructured parameters", ->
  fn = ({@foo}, [@bar], [{@baz}]) ->
    foo = bar = baz = false

  fn.call {}, {foo: 'foo'}, ['bar'], [{baz: 'baz'}]

  eq 'undefined', typeof foo
  eq 'undefined', typeof bar
  eq 'undefined', typeof baz
# Slicing and Splicing
# --------------------

# * Slicing
# * Splicing

# shared array
shared = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

# Slicing

test "basic slicing", ->
  arrayEq [7, 8, 9]   , shared[7..9]
  arrayEq [2, 3]      , shared[2...4]
  arrayEq [2, 3, 4, 5], shared[2...6]

test "slicing with variables as endpoints", ->
  [a, b] = [1, 4]
  arrayEq [1, 2, 3, 4], shared[a..b]
  arrayEq [1, 2, 3]   , shared[a...b]

test "slicing with expressions as endpoints", ->
  [a, b] = [1, 3]
  arrayEq [2, 3, 4, 5, 6], shared[(a+1)..2*b]
  arrayEq [2, 3, 4, 5]   , shared[a+1...(2*b)]

test "unbounded slicing", ->
  arrayEq [7, 8, 9]   , shared[7..]
  arrayEq [8, 9]      , shared[-2..]
  arrayEq [9]         , shared[-1...]
  arrayEq [0, 1, 2]   , shared[...3]
  arrayEq [0, 1, 2, 3], shared[..-7]

  arrayEq shared      , shared[..-1]
  arrayEq shared[0..8], shared[...-1]

  for a in [-shared.length..shared.length]
    arrayEq shared[a..] , shared[a...]
  for a in [-shared.length+1...shared.length]
    arrayEq shared[..a][...-1] , shared[...a]

  arrayEq [1, 2, 3], [1, 2, 3][..]

test "#930, #835, #831, #746 #624: inclusive slices to -1 should slice to end", ->
  arrayEq shared, shared[0..-1]
  arrayEq shared, shared[..-1]
  arrayEq shared.slice(1,shared.length), shared[1..-1]

test "string slicing", ->
  str = "abcdefghijklmnopqrstuvwxyz"
  ok str[1...1] is ""
  ok str[1..1] is "b"
  ok str[1...5] is "bcde"
  ok str[0..4] is "abcde"
  ok str[-5..] is "vwxyz"

test "#1722: operator precedence in unbounded slice compilation", ->
  list = [0..9]
  n = 2 # some truthy number in `list`
  arrayEq [0..n], list[..n]
  arrayEq [0..n], list[..n or 0]
  arrayEq [0..n], list[..if n then n else 0]

test "#2349: inclusive slicing to numeric strings", ->
  arrayEq [0, 1], [0..10][.."1"]


# Splicing

test "basic splicing", ->
  ary = [0..9]
  ary[5..9] = [0, 0, 0]
  arrayEq [0, 1, 2, 3, 4, 0, 0, 0], ary

  ary = [0..9]
  ary[2...8] = []
  arrayEq [0, 1, 8, 9], ary

test "unbounded splicing", ->
  ary = [0..9]
  ary[3..] = [9, 8, 7]
  arrayEq [0, 1, 2, 9, 8, 7]. ary

  ary[...3] = [7, 8, 9]
  arrayEq [7, 8, 9, 9, 8, 7], ary

  ary[..] = [1, 2, 3]
  arrayEq [1, 2, 3], ary

test "splicing with variables as endpoints", ->
  [a, b] = [1, 8]

  ary = [0..9]
  ary[a..b] = [2, 3]
  arrayEq [0, 2, 3, 9], ary

  ary = [0..9]
  ary[a...b] = [5]
  arrayEq [0, 5, 8, 9], ary

test "splicing with expressions as endpoints", ->
  [a, b] = [1, 3]

  ary = [0..9]
  ary[ a+1 .. 2*b+1 ] = [4]
  arrayEq [0, 1, 4, 8, 9], ary

  ary = [0..9]
  ary[a+1...2*b+1] = [4]
  arrayEq [0, 1, 4, 7, 8, 9], ary

test "splicing to the end, against a one-time function", ->
  ary = null
  fn = ->
    if ary
      throw 'err'
    else
      ary = [1, 2, 3]

  fn()[0..] = 1

  arrayEq ary, [1]

test "the return value of a splice literal should be the RHS", ->
  ary = [0, 0, 0]
  eq (ary[0..1] = 2), 2

  ary = [0, 0, 0]
  eq (ary[0..] = 3), 3

  arrayEq [ary[0..0] = 0], [0]

test "#1723: operator precedence in unbounded splice compilation", ->
  n = 4 # some truthy number in `list`

  list = [0..9]
  list[..n] = n
  arrayEq [n..9], list

  list = [0..9]
  list[..n or 0] = n
  arrayEq [n..9], list

  list = [0..9]
  list[..if n then n else 0] = n
  arrayEq [n..9], list

test "#2953: methods on endpoints in assignment from array splice literal", ->
  list = [0..9]

  Number.prototype.same = -> this
  list[1.same()...9.same()] = 5
  delete Number.prototype.same

  arrayEq [0, 5, 9], list
# Soaks
# -----

# * Soaked Property Access
# * Soaked Method Invocation
# * Soaked Function Invocation


# Soaked Property Access

test "soaked property access", ->
  nonce = {}
  obj = a: b: nonce
  eq nonce    , obj?.a.b
  eq nonce    , obj?['a'].b
  eq nonce    , obj.a?.b
  eq nonce    , obj?.a?['b']
  eq undefined, obj?.a?.non?.existent?.property

test "soaked property access caches method calls", ->
  nonce ={}
  obj = fn: -> a: nonce
  eq nonce    , obj.fn()?.a
  eq undefined, obj.fn()?.b

test "soaked property access caching", ->
  nonce = {}
  counter = 0
  fn = ->
    counter++
    'self'
  obj =
    self: -> @
    prop: nonce
  eq nonce, obj[fn()]()[fn()]()[fn()]()?.prop
  eq 3, counter

test "method calls on soaked methods", ->
  nonce = {}
  obj = null
  eq undefined, obj?.a().b()
  obj = a: -> b: -> nonce
  eq nonce    , obj?.a().b()

test "postfix existential operator mixes well with soaked property accesses", ->
  eq false, nonexistent?.property?

test "function invocation with soaked property access", ->
  id = (_) -> _
  eq undefined, id nonexistent?.method()

test "if-to-ternary should safely parenthesize soaked property accesses", ->
  ok (if nonexistent?.property then false else true)

test "#726", ->
  # TODO: check this test, looks like it's not really testing anything
  eq undefined, nonexistent?[Date()]

test "#756", ->
  # TODO: improve this test
  a = null
  ok isNaN      a?.b.c +  1
  eq undefined, a?.b.c += 1
  eq undefined, ++a?.b.c
  eq undefined, delete a?.b.c

test "operations on soaked properties", ->
  # TODO: improve this test
  a = b: {c: 0}
  eq 1,   a?.b.c +  1
  eq 1,   a?.b.c += 1
  eq 2,   ++a?.b.c
  eq yes, delete a?.b.c


# Soaked Method Invocation

test "soaked method invocation", ->
  nonce = {}
  counter = 0
  obj =
    self: -> @
    increment: -> counter++; @
  eq obj      , obj.self?()
  eq undefined, obj.method?()
  eq nonce    , obj.self?().property = nonce
  eq undefined, obj.method?().property = nonce
  eq obj      , obj.increment().increment().self?()
  eq 2        , counter

test "#733", ->
  a = b: {c: null}
  eq a.b?.c?(), undefined
  a.b?.c or= (it) -> it
  eq a.b?.c?(1), 1
  eq a.b?.c?([2, 3]...), 2


# Soaked Function Invocation

test "soaked function invocation", ->
  nonce = {}
  id = (_) -> _
  eq nonce    , id?(nonce)
  eq nonce    , (id? nonce)
  eq undefined, nonexistent?(nonce)
  eq undefined, (nonexistent? nonce)

test "soaked function invocation with generated functions", ->
  nonce = {}
  id = (_) -> _
  maybe = (fn, arg) -> if typeof fn is 'function' then () -> fn(arg)
  eq maybe(id, nonce)?(), nonce
  eq (maybe id, nonce)?(), nonce
  eq (maybe false, nonce)?(), undefined

test "soaked constructor invocation", ->
  eq 42       , +new Number? 42
  eq undefined,  new Other?  42

test "soaked constructor invocations with caching and property access", ->
  semaphore = 0
  nonce = {}
  class C
    constructor: ->
      ok false if semaphore
      semaphore++
    prop: nonce
  eq nonce, (new C())?.prop
  eq 1, semaphore

test "soaked function invocation safe on non-functions", ->
  eq undefined, (0)?(1)
  eq undefined, (0)? 1, 2
return if global.testingBrowser

SourceMap = require '../src/sourcemap'

vlqEncodedValues = [
    [1, "C"],
    [-1, "D"],
    [2, "E"],
    [-2, "F"],
    [0, "A"],
    [16, "gB"],
    [948, "o7B"]
]

test "encodeVlq tests", ->
  for pair in vlqEncodedValues
    eq ((new SourceMap).encodeVlq pair[0]), pair[1]

eqJson = (a, b) ->
  eq (JSON.stringify JSON.parse a), (JSON.stringify JSON.parse b)

test "SourceMap tests", ->
  map = new SourceMap
  map.add [0, 0], [0, 0]
  map.add [1, 5], [2, 4]
  map.add [1, 6], [2, 7]
  map.add [1, 9], [2, 8]
  map.add [3, 0], [3, 4]

  testWithFilenames = map.generate {
        sourceRoot: "",
        sourceFiles: ["source.coffee"],
        generatedFile: "source.js"}
  eqJson testWithFilenames, '{"version":3,"file":"source.js","sourceRoot":"","sources":["source.coffee"],"names":[],"mappings":"AAAA;;IACK,GAAC,CAAG;IAET"}'
  eqJson map.generate(), '{"version":3,"file":"","sourceRoot":"","sources":[""],"names":[],"mappings":"AAAA;;IACK,GAAC,CAAG;IAET"}'

  # Look up a generated column - should get back the original source position.
  arrayEq map.sourceLocation([2,8]), [1,9]

  # Look up a point futher along on the same line - should get back the same source position.
  arrayEq map.sourceLocation([2,10]), [1,9]
# Strict Early Errors
# -------------------

# The following are prohibited under ES5's `strict` mode
# * `Octal Integer Literals`
# * `Octal Escape Sequences`
# * duplicate property definitions in `Object Literal`s
# * duplicate formal parameter
# * `delete` operand is a variable
# * `delete` operand is a parameter
# * `delete` operand is `undefined`
# * `Future Reserved Word`s as identifiers: implements, interface, let, package, private, protected, public, static, yield
# * `eval` or `arguments` as `catch` identifier
# * `eval` or `arguments` as formal parameter
# * `eval` or `arguments` as function declaration identifier
# * `eval` or `arguments` as LHS of assignment
# * `eval` or `arguments` as the operand of a post/pre-fix inc/dec-rement expression

# helper to assert that code complies with strict prohibitions
strict = (code, msg) ->
  throws (-> CoffeeScript.compile code), null, msg ? code
strictOk = (code, msg) ->
  doesNotThrow (-> CoffeeScript.compile code), msg ? code


test "octal integer literals prohibited", ->
  strict    '01'
  strict    '07777'
  # decimals with a leading '0' are also prohibited
  strict    '09'
  strict    '079'
  strictOk  '`01`'

test "octal escape sequences prohibited", ->
  strict    '"\\1"'
  strict    '"\\7"'
  strict    '"\\001"'
  strict    '"\\777"'
  strict    '"_\\1"'
  strict    '"\\1_"'
  strict    '"_\\1_"'
  strict    '"\\\\\\1"'
  strictOk  '"\\0"'
  eq "\x00", "\0"
  strictOk  '"\\08"'
  eq "\x008", "\08"
  strictOk  '"\\0\\8"'
  eq "\x008", "\0\8"
  strictOk  '"\\8"'
  eq "8", "\8"
  strictOk  '"\\\\1"'
  eq "\\" + "1", "\\1"
  strictOk  '"\\\\\\\\1"'
  eq "\\\\" + "1", "\\\\1"
  strictOk  "`'\\1'`"
  eq "\\" + "1", `"\\1"`

test "duplicate formal parameters are prohibited", ->
  nonce = {}
  # a Param can be an Identifier, ThisProperty( @-param ), Array, or Object
  # a Param can also be a splat (...) or an assignment (param=value)
  # the following function expressions should throw errors
  strict '(_,_)->',          'param, param'
  strict '(_,@_)->',         'param, @param'
  strict '(_,_...)->',       'param, param...'
  strict '(@_,_...)->',      '@param, param...'
  strict '(_,_ = true)->',   'param, param='
  strict '(@_,@_)->',        'two @params'
  strict '(_,@_ = true)->',  'param, @param='
  strict '(_,{_})->',        'param, {param}'
  strict '(@_,{_})->',       '@param, {param}'
  strict '({_,_})->',        '{param, param}'
  strict '({_,@_})->',       '{param, @param}'
  strict '(_,[_])->',        'param, [param]'
  strict '([_,_])->',        '[param, param]'
  strict '([_,@_])->',       '[param, @param]'
  strict '(_,[_]=true)->',   'param, [param]='
  strict '(_,[@_,{_}])->',   'param, [@param, {param}]'
  strict '(_,[_,{@_}])->',   'param, [param, {@param}]'
  strict '(_,[_,{_}])->',    'param, [param, {param}]'
  strict '(_,[_,{__}])->',   'param, [param, {param2}]'
  strict '(_,[__,{_}])->',   'param, [param2, {param}]'
  strict '(__,[_,{_}])->',   'param, [param2, {param2}]'
  strict '(0:a,1:a)->',      '0:param,1:param'
  strict '({0:a,1:a})->',    '{0:param,1:param}'
  # the following function expressions should **not** throw errors
  strictOk '({},_arg)->'
  strictOk '({},{})->'
  strictOk '([]...,_arg)->'
  strictOk '({}...,_arg)->'
  strictOk '({}...,[],_arg)->'
  strictOk '([]...,{},_arg)->'
  strictOk '(@case,_case)->'
  strictOk '(@case,_case...)->'
  strictOk '(@case...,_case)->'
  strictOk '(_case,@case)->'
  strictOk '(_case,@case...)->'
  strictOk '(a:a)->'
  strictOk '(a:a,a:b)->'

test "`delete` operand restrictions", ->
  strict 'a = 1; delete a'
  strictOk 'delete a' #noop
  strict '(a) -> delete a'
  strict '(@a) -> delete a'
  strict '(a...) -> delete a'
  strict '(a = 1) -> delete a'
  strict '([a]) -> delete a'
  strict '({a}) -> delete a'

test "`Future Reserved Word`s, `eval` and `arguments` restrictions", ->

  access = (keyword, check = strict) ->
    check "#{keyword}.a = 1"
    check "#{keyword}[0] = 1"
  assign = (keyword, check = strict) ->
    check "#{keyword} = 1"
    check "#{keyword} += 1"
    check "#{keyword} -= 1"
    check "#{keyword} *= 1"
    check "#{keyword} /= 1"
    check "#{keyword} ?= 1"
    check "{keyword}++"
    check "++{keyword}"
    check "{keyword}--"
    check "--{keyword}"
  destruct = (keyword, check = strict) ->
    check "{#{keyword}}"
    check "o = {#{keyword}}"
  invoke = (keyword, check = strict) ->
    check "#{keyword} yes"
    check "do #{keyword}"
  fnDecl = (keyword, check = strict) ->
    check "class #{keyword}"
  param = (keyword, check = strict) ->
    check "(#{keyword}) ->"
    check "({#{keyword}}) ->"
  prop = (keyword, check = strict) ->
    check "a.#{keyword} = 1"
  tryCatch = (keyword, check = strict) ->
    check "try new Error catch #{keyword}"

  future = 'implements interface let package private protected public static yield'.split ' '
  for keyword in future
    access   keyword
    assign   keyword
    destruct keyword
    invoke   keyword
    fnDecl   keyword
    param    keyword
    prop     keyword, strictOk
    tryCatch keyword

  for keyword in ['eval', 'arguments']
    access   keyword, strictOk
    assign   keyword
    destruct keyword, strictOk
    invoke   keyword, strictOk
    fnDecl   keyword
    param    keyword
    prop     keyword, strictOk
    tryCatch keyword
# String Literals
# ---------------

# TODO: refactor string literal tests
# TODO: add indexing and method invocation tests: "string"["toString"] is String::toString, "string".toString() is "string"

# * Strings
# * Heredocs

test "backslash escapes", ->
  eq "\\/\\\\", /\/\\/.source

eq '(((dollars)))', '\(\(\(dollars\)\)\)'
eq 'one two three', "one
 two
 three"
eq "four five", 'four

 five'

test "#3229, multiline strings", ->
  # Separate lines by default by a single space in literal strings.
  eq 'one
      two', 'one two'
  eq "one
      two", 'one two'
  eq '
        a
        b
    ', 'a b'
  eq "
        a
        b
    ", 'a b'
  eq 'one

        two', 'one two'
  eq "one

        two", 'one two'
  eq '
    indentation
      doesn\'t
  matter', 'indentation doesn\'t matter'
  eq 'trailing ws      
    doesn\'t matter', 'trailing ws doesn\'t matter'

  # Use backslashes at the end of a line to specify whitespace between lines.
  eq 'a \
      b\
      c  \
      d', 'a bc  d'
  eq "a \
      b\
      c  \
      d", 'a bc  d'
  eq 'ignore  \  
      trailing whitespace', 'ignore  trailing whitespace'

  # Backslash at the beginning of a literal string.
  eq '\
      ok', 'ok'
  eq '  \
      ok', '  ok'

  # #1273, empty strings.
  eq '\
     ', ''
  eq '
     ', ''
  eq '
          ', ''
  eq '   ', '   '

  # Same behavior in interpolated strings.
  eq "interpolation #{1}
      follows #{2}  \
      too #{3}\
      !", 'interpolation 1 follows 2  too 3!'
  eq "a #{
    'string ' + "inside
                 interpolation"
    }", "a string inside interpolation"
  eq "
      #{1}
     ", '1'

  # Handle escaped backslashes correctly.
  eq '\\', `'\\'`
  eq 'escaped backslash at EOL\\
      next line', 'escaped backslash at EOL\\ next line'
  eq '\\
      next line', '\\ next line'
  eq '\\
     ', '\\'
  eq '\\\\\\
     ', '\\\\\\'
  eq "#{1}\\
      after interpolation", '1\\ after interpolation'
  eq 'escaped backslash before slash\\  \
      next line', 'escaped backslash before slash\\  next line'
  eq 'triple backslash\\\
      next line', 'triple backslash\\next line'
  eq 'several escaped backslashes\\\\\\
      ok', 'several escaped backslashes\\\\\\ ok'
  eq 'several escaped backslashes slash\\\\\\\
      ok', 'several escaped backslashes slash\\\\\\ok'
  eq 'several escaped backslashes with trailing ws \\\\\\   
      ok', 'several escaped backslashes with trailing ws \\\\\\ ok'

  # Backslashes at beginning of lines.
  eq 'first line
      \   backslash at BOL', 'first line \   backslash at BOL'
  eq 'first line\
      \   backslash at BOL', 'first line\   backslash at BOL'

  # Edge case.
  eq 'lone

        \

        backslash', 'lone backslash'

test "#3249, escape newlines in heredocs with backslashes", ->
  # Ignore escaped newlines
  eq '''
    Set whitespace      \
       <- this is ignored\  
           none
      normal indentation
    ''', 'Set whitespace      <- this is ignorednone\n  normal indentation'
  eq """
    Set whitespace      \
       <- this is ignored\  
           none
      normal indentation
    """, 'Set whitespace      <- this is ignorednone\n  normal indentation'

  # Changed from #647, trailing backslash.
  eq '''
  Hello, World\

  ''', 'Hello, World'
  eq '''
    \\
  ''', '\\'

  # Backslash at the beginning of a literal string.
  eq '''\
      ok''', 'ok'
  eq '''  \
      ok''', '  ok'

  # Same behavior in interpolated strings.
  eq """
    interpolation #{1}
      follows #{2}  \
        too #{3}\
    !
  """, 'interpolation 1\n  follows 2  too 3!'
  eq """

    #{1} #{2}

    """, '\n1 2\n'

  # TODO: uncomment when #2388 is fixed
  # eq """a heredoc #{
  #     "inside \
  #       interpolation"
  #   }""", "a heredoc inside interpolation"

  # Handle escaped backslashes correctly.
  eq '''
    escaped backslash at EOL\\
      next line
  ''', 'escaped backslash at EOL\\\n  next line'
  eq '''\\

     ''', '\\\n'

  # Backslashes at beginning of lines.
  eq '''first line
      \   backslash at BOL''', 'first line\n\   backslash at BOL'
  eq """first line\
      \   backslash at BOL""", 'first line\   backslash at BOL'

  # Edge cases.
  eq '''lone

          \



        backslash''', 'lone\n\n  backslash'
  eq '''\
     ''', ''

#647
eq "''Hello, World\\''", '''
'\'Hello, World\\\''
'''
eq '""Hello, World\\""', """
"\"Hello, World\\\""
"""

test "#1273, escaping quotes at the end of heredocs.", ->
  # """\""" no longer compiles
  eq """\\""", '\\'
  eq """\\\"""", '\\\"'

a = """
    basic heredoc
    on two lines
    """
ok a is "basic heredoc\non two lines"

a = '''
    a
      "b
    c
    '''
ok a is "a\n  \"b\nc"

a = """
a
 b
  c
"""
ok a is "a\n b\n  c"

a = '''one-liner'''
ok a is 'one-liner'

a = """
      out
      here
"""
ok a is "out\nhere"

a = '''
       a
     b
   c
    '''
ok a is "    a\n  b\nc"

a = '''
a


b c
'''
ok a is "a\n\n\nb c"

a = '''more"than"one"quote'''
ok a is 'more"than"one"quote'

a = '''here's an apostrophe'''
ok a is "here's an apostrophe"

# The indentation detector ignores blank lines without trailing whitespace
a = """
    one
    two

    """
ok a is "one\ntwo\n"

eq ''' line 0
  should not be relevant
    to the indent level
''', ' line 0\nshould not be relevant\n  to the indent level'

eq ''' '\\\' ''', " '\\' "
eq """ "\\\" """, ' "\\" '

eq '''  <- keep these spaces ->  ''', '  <- keep these spaces ->  '


test "#1046, empty string interpolations", ->
  eq "#{ }", ''
