class VM
  def initialize(environment = {})
    @environment = environment
  end

  def run(expression)
    p "#{expression} | #{@environment}"

    while expression.reducible?
      expression, @environment = expression.reduce(@environment)
      p "#{expression} | #{@environment}"
    end
    expression
  end
end

# expression
class Variable
  attr_accessor :key

  def initialize(key)
    @key = key
  end

  def reduce(environment)
    environment[@key]
  end

  def reducible?
    true
  end

  def to_s
    @key.to_s
  end
end

class Number
  attr_accessor :val

  def initialize(val)
    @val = val
  end

  def reducible?
    false
  end

  def to_s
    @val.to_s
  end

  def inspect
    "<< #{@val} >>"
  end
end

class Boolean
  attr_accessor :val

  def initialize(val)
    @val = val
  end

  def reducible?
    false
  end

  def to_s
    "#{@val}"
  end

  def inspect
    "<< #{self} >>"
  end
end

class Add
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def reduce(environment)
    if @left.reducible?
      Add.new(@left.reduce(environment), @right)
    elsif @right.reducible?
      Add.new(@left, @right.reduce(environment))
    else
      Number.new(@left.val + @right.val)
    end
  end

  def reducible?
    true
  end

  def to_s
    "(#{@left} + #{@right})"
  end

  def inspect
    "<< #{@left} + #{@right} >>"
  end
end

class Multiply
  def initialize(left, right)
    @left = left
    @right = right
  end

  def reduce(environment)
    if @left.reducible?
      Multiply.new(@left.reduce(environment), @right)
    elsif @right.reducible?
      Multiply.new(@left, @right.reduce(environment))
    else
      Number.new(@left.val * @right.val)
    end
  end

  def reducible?
    true
  end

  def to_s
    "(#{@left} * #{@right})"
  end

  def inspect
    "<< #{@left} * #{@right} >>"
  end
end

# statement
class DoNothing
  def to_s
    "do nothing"
  end

  def reducible?
    false
  end

  def inspect
    "<< do nothing >>"
  end
end

class Assign
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def reduce(environment)
    if @right.reducible?
      [Assign.new(@left, @right.reduce(environment)), environment]
    else
      [DoNothing.new, environment.merge(@left.key => Number.new(@right.val))]
    end
  end

  def reducible?
    true
  end

  def to_s
    "#{@left} = #{@right}"
  end

  def inspect
    "<< #{@left} = #{@right} >>"
  end
end

class Sequence
  attr_accessor :first
  attr_accessor :second

  def initialize(first, second)
    @first = first
    @second = second
  end

  def reduce(environment)
    if @first.is_a? DoNothing
      [@second, environment]
    else
      first, env = @first.reduce(environment)
      [Sequence.new(first, @second), env]
    end
  end

  def reducible?
    true
  end

  def to_s
    "#{@first}; #{@second}"
  end

  def inspect
    "<< #{@first}; #{@second} >>"
  end
end

class If
  attr_accessor :cond
  attr_accessor :consequence
  attr_accessor :alternative

  def initialize(cond, consequence, alternative)
    @cond = cond
    @consequence = consequence
    @alternative = alternative
  end

  def reduce(environment)
    if @cond.reducible?
      [If.new(@cond.reduce(environment), @consequence, @alternative), environment]
    else
      if @cond.val == Boolean.new(true).val
        return [DoNothing.new, environment] if @consequence.is_a? DoNothing
        result, env = @consequence.reduce(environment)
        [result, env]
      else
        return [DoNothing.new, environment] if @alternative.is_a? DoNothing

        result, env = @alternative.reduce(environment)
        [result, env]
      end
    end
  end

  def reducible?
    true
  end

  def to_s
    "#{@cond} ? (#{@consequence}) : (#{@alternative})"
  end

  def inspect
    "<< if (#{@cond}) { #{@consequence} } else { #{@alternative} } >>"
  end
end

class LessThan
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def reduce(environment)
    if @left.reducible?
      LessThan.new(@left.reduce(environment), @right)
    elsif @right.reducible?
      LessThan.new(@left, @right.reduce(environment))
    else
      Boolean.new(@left.val < @right.val)
    end
  end

  def reducible?
    true
  end

  def to_s
    "#{@left} < #{@right}"
  end

  def inspect
    "<< #{@left} < #{@right} >>"
  end
end

class MoreThan
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def reduce(environment)
    if @left.reducible?
      MoreThan.new(@left.reduce(environment), @right)
    elsif @right.reducible?
      MoreThan.new(@left, @right.reduce(environment))
    else
      Boolean.new(@left.val > @right.val)
    end
  end

  def reducible?
    true
  end

  def to_s
    "#{@left} > #{@right}"
  end

  def inspect
    "<< #{@left} > #{@right} >>"
  end
end

class Equal
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def reduce(environment)
    if @left.reducible?
      Equal.new(@left.reduce(environment), @right)
    elsif @right.reducible?
      Equal.new(@left, @right.reduce(environment))
    else
      Boolean.new(@left.val == @right.val)
    end
  end

  def reducible?
    true
  end

  def to_s
    "#{@left} == #{@right}"
  end

  def inspect
    "<< #{@left} == #{@right} >>"
  end
end

class While
  attr_accessor :cond
  attr_accessor :body

  def initialize(cond, body)
    @cond = cond
    @body = body
  end

  def reduce(environment)
    [If.new(@cond, Sequence.new(@body, self), DoNothing.new), environment]
  end

  def reducible?
    true
  end

  def to_s
    "while (#{@cond}) { #{body} }"
  end

  def inspect
    "<< while (#{@cond}) { #{body} } >>"
  end
end

# 验证加法运算
p Add.new(Number.new(1), Number.new(2))

# 验证多元加法运算
p Add.new(Number.new(1), Add.new(Number.new(1), Number.new(2)))

# 验证乘法运算
p Multiply.new(Number.new(1), Number.new(2))

# 验证乘法与加法混合运算
p Multiply.new(Number.new(1), Add.new(Number.new(1), Add.new(Number.new(1), Number.new(2))))

# 验证虚拟机自动规约
p VM.new.run(
  Add.new(
    Number.new(1),
    Multiply.new(
      Number.new(2),
      Number.new(3)
    )
  )
)

# 验证变量参与运算
p VM.new({
    x: Number.new(20),
  }).run(
    Add.new(
      Number.new(10),
      Variable.new(:x)
    )
  )

# 验证赋值语句
p VM.new({
    x: Number.new(20),
  }).run(
    Assign.new(
      Variable.new(:x),
      Number.new(40)
    )
  )

# 验证序列语句
p VM.new({
    x: Number.new(20),
  }).run(
    Sequence.new(
      Assign.new(
        Variable.new(:x),
        Number.new(40)
      ),
      Add.new(
        Number.new(1),
        Variable.new(:x)
      )
    )
  )

# 验证条件判断
p VM.new({
    x: Number.new(100),
    y: Number.new(10),
  }).run(
    If.new(
      Equal.new(
        Variable.new(:x),
        Number.new(100)
      ),
      Sequence.new(
        Assign.new(
          Variable.new(:x),
          Multiply.new(
            Variable.new(:x),
            Number.new(2)
          )
        ),
        Assign.new(
          Variable.new(:y),
          Multiply.new(
            Variable.new(:y),
            Number.new(2)
          )
        )
      ),
      Sequence.new(
        Assign.new(
          Variable.new(:x),
          Number.new(10)
        ),
        Assign.new(
          Variable.new(:y),
          Add.new(
            Variable.new(:y),
            Variable.new(:x)
          )
        )
      )
    )
  )

# 验证 while 实现，通过小步规约求和 1 + 2 + 3 + ... + 99 + 100
p VM.new({
    x: Number.new(1),
    sum: Number.new(0),
  }).run(
    While.new(
      LessThan.new(
        Variable.new(:x),
        Number.new(101)
      ),
      Sequence.new(
        Assign.new(
          Variable.new(:sum),
          Add.new(
            Variable.new(:sum),
            Variable.new(:x)
          )
        ),
        Assign.new(
          Variable.new(:x),
          Add.new(
            Variable.new(:x),
            Number.new(1)
          )
        )
      )
    )
  )
