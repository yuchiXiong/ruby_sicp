class VM
  attr_accessor :environment

  def initialize(environment = {})
    @environment = environment
  end

  def run(expression)
    expression.evaluate(@environment)
  end
end

# expression
class Variable
  attr_accessor :key

  def initialize(key)
    @key = key
  end

  def evaluate(environment)
    environment[@key]
  end
end

class Number
  attr_accessor :val

  def initialize(val)
    @val = val
  end

  def evaluate(environment)
    self
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

  def evaluate(environment)
    self
  end

  def inspect
    "<< #{@val} >>"
  end
end

class Add
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(environment)
    Number.new(@left.evaluate(environment).val + @right.evaluate(environment).val)
  end
end

class Multiply
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(environment)
    Number.new(@left.evaluate(environment).val * @right.evaluate(environment).val)
  end
end

# statement
class DoNothing
  def initialize
  end

  def evaluate(environment)
    environment
  end
end

class Assign
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(environment)
    environment.merge(@left.key => @right.evaluate(environment))
  end
end

class Sequence
  attr_accessor :first
  attr_accessor :second

  def initialize(first, second)
    @first = first
    @second = second
  end

  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
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

  def evaluate(environment)
    if @cond.evaluate(environment).val == Boolean.new(true).val
      @consequence.evaluate(environment)
    else
      @alternative.evaluate(environment)
    end
  end
end

class LessThan
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(environment)
    Boolean.new(@left.evaluate(environment).val < @right.evaluate(environment).val)
  end
end

class MoreThan
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(environment)
    Boolean.new(@left.evaluate(environment).val > @right.evaluate(environment).val)
  end
end

class Equal
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(environment)
    Boolean.new(@left.evaluate(environment).val == @right.evaluate(environment).val)
  end
end

class While
  attr_accessor :cond
  attr_accessor :body

  def initialize(cond, body)
    @cond = cond
    @body = body
  end

  def evaluate(environment)
    if @cond.evaluate(environment).val == Boolean.new(true).val
      evaluate(body.evaluate(environment))
    else
      environment
    end
  end
end

p Add.new(Number.new(1), Number.new(2)).evaluate({})
p Multiply.new(Number.new(8), Number.new(2)).evaluate({})
p VM.new({
    x: Number.new(20),
  }).run(
    Add.new(Variable.new(:x), Number.new(8))
  )
p VM.new({
    x: Number.new(20),
  }).run(
    Boolean.new(true)
  )
p VM.new({
    x: Number.new(20),
  }).run(
    Assign.new(
      Variable.new(:x),
      Number.new(100)
    )
  )

p VM.new({
    x: Number.new(20),
  }).run(
    Sequence.new(
      Assign.new(
        Variable.new(:x),
        Number.new(100)
      ),
      Assign.new(
        Variable.new(:x),
        Multiply.new(
          Variable.new(:x),
          Number.new(5)
        )
      ),
    )
  )

p VM.new({
    x: Number.new(3),
  }).run(
    If.new(
      LessThan.new(
        Variable.new(:x),
        Number.new(2)
      ),
      Assign.new(
        Variable.new(:x),
        Number.new(2)
      ),
      Sequence.new(
        Assign.new(
          Variable.new(:x),
          Add.new(
            Variable.new(:x),
            Number.new(2)
          )
        ),
        Assign.new(
          Variable.new(:x),
          Multiply.new(
            Variable.new(:x),
            Number.new(10)
          )
        )
      )
    )
  )

p VM.new({
    n: Number.new(1),
    sum: Number.new(0),
  }).run(
    While.new(
      LessThan.new(
        Variable.new(:n),
        Number.new(101)
      ),
      Sequence.new(
        Assign.new(
          Variable.new(:sum),
          Add.new(
            Variable.new(:sum),
            Variable.new(:n)
          )
        ),
        Assign.new(
          Variable.new(:n),
          Add.new(
            Variable.new(:n),
            Number.new(1)
          )
        )
      )
    )
  )
