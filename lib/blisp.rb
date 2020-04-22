BUILTINS = {
  :+ => ->(xs) { xs.reduce(:+) },
  :* => ->(xs) { xs.reduce(:*) },
  :eq => ->(xs) { xs.reduce(:==) ? :true : :false },
  :quot => ->(items) { [:quot, *items] }
}

module Blisp
  def self.eval(expr)
    case expr
    in [:quot, *items]
      expr
    in [:cond, *items]
      cond(*items)
    in [:let, name, value, *rest]
      eval(replace(rest, name, value))
    in [func, *args]
      apply(eval(func), args.map(&method(:eval)))
    else
      expr
    end
  end

  def self.cond(condition, consequent, *rest)
    if eval(condition) == :true
      eval(consequent)
    elsif rest.empty?
      raise "No conditions matched in cond expression"
    else
      cond(*rest)
    end
  end

  def self.apply(func, args)
    if BUILTINS[func]
      return BUILTINS[func].(args)
    end

    case [func, args]
    in [:quot, param, *rest], [arg, *rest_of_args]
      apply(
        [ :quot,
          *add_refs(rest, param, [:ref, arg])
        ],
        rest_of_args
      )
    in [:quot, body], []
      eval(inline_refs(body))
    in [:quot, *rest], []
      func
    in Array, _
      raise "You've found a bug! #{func.inspect} is being used as a function, but isn't quoted, which shouldn't be possible"
    else
      raise "Can't use #{func.inspect} as a function"
    end
  end

  def self.inline_refs(thing)
    case thing
    in [:ref, x]
      x
    in Array => a
      a.map { |elem| inline_refs(elem) }
    else
      thing
    end
  end

  def self.add_refs(expr, var, value)
    case expr
    in ^var
      value
    in [:ref, _] => ref
      ref
    in Array => a
      a.map { |elem| add_refs(elem, var, value) }
    else
      expr
    end
  end

  def self.replace(expr, var, value)
    case expr
    in ^var
      value
    in Array => a
      a.map { |elem| replace(elem, var, value) }
    else
      expr
    end
  end
end
