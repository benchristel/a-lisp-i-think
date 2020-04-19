require_relative "../lib/blisp"

describe Blisp do
  it "evaluates a number" do
    expect(Blisp.eval(1)).to be 1
  end

  it "evaluates a string" do
    expect(Blisp.eval("hello")).to eq "hello"
  end

  it "evaluates a symbol" do
    expect(Blisp.eval(:wow)).to be :wow
  end

  it "evaluates a list" do
    expect(Blisp.eval([:quot, 1, 2])).to eq [:quot, 1, 2]
  end

  it "evaluates an empty list" do
    expect(Blisp.eval([:quot])).to eq [:quot]
  end

  it "has built-in addition" do
    expect(Blisp.eval([:+, 1, 2])).to eq 3
    expect(Blisp.eval([:+, 1, 1, 1, 1])).to eq 4
  end

  it "has built-in multiplication" do
    expect(Blisp.eval([:*, 3, 2])).to eq 6
    expect(Blisp.eval([:*, 2, 2, 2, 2])).to eq 16
  end

  it "nests mathematical operations" do
    expect(Blisp.eval([:+, 1, [:*, 3, 5]])).to eq 16
  end

  it "calls a custom function" do
    expect(Blisp.eval([[:quot, :x, :x], 1])).to be 1
  end

  it "evaluates a function with multiple parameters" do
    car = [:quot, :a, :b, :a]
    cdr = [:quot, :a, :b, :b]
    expect(Blisp.eval([car, 1, 2])).to be 1
    expect(Blisp.eval([cdr, 1, 2])).to be 2
  end

  it "evaluates a function with zero parameters" do
    thunk = [:quot, 1]
    expect(Blisp.eval([thunk])).to be 1
  end

  it "evaluates the predicate of an application before applying it" do
    expect(Blisp.eval([[:quot, :x, [:+, :x, 1]], 1])).to be 2
  end

  it "partially applies a function" do
    car = [:quot, :a, :b, :a]
    expect(Blisp.eval([car, 1])).to eq [:quot, :b, [:ref, 1]]
  end

  it "evaluates a variable in a nested list expression" do
    my_quot = [:quot, :x, [:quot, :x]]
    expect(Blisp.eval([my_quot, 1])).to eq [:quot, 1]
  end

  it "hygenically replaces variables" do
    car = [:quot, :a, :b, :a]
    problematic_arg = :b
    expect(Blisp.eval([car, problematic_arg, :do_not_want]))
      .to eq :b
  end

  it "raises an error if you try to apply something that's not a function" do
    expect {
      Blisp.eval([1, 2])
    }.to raise_error "Can't use 1 as a function"
  end

  it "creates higher-order functions" do
    incr    = [:quot, :x, [:+, 1, :x]]
    double  = [:quot, :x, [:*, 2, :x]]
    compose = [:quot, :f, :g, :x, [:f, [:g, :x]]]
    expect(Blisp.eval([[compose, double, incr], 3])).to be 8
  end

  it "evaluates expressions conditionally" do
    expect(Blisp.eval([:cond, :true, 1, :false, 2])).to be 1
    expect(Blisp.eval([:cond, :false, 1, :true, 2])).to be 2
  end

  it "complains if no condition is true" do
    expect { Blisp.eval([:cond, :false, 1]) }
      .to raise_error "No conditions matched in cond expression"
  end

  it "compares integers for equality" do
    expect(Blisp.eval([:eq, 1, 2])).to be :false
    expect(Blisp.eval([:eq, 1, 1])).to be :true
  end

  it "recurses" do
    factorial = [:quot, :factorial, :n,
      [:cond,
        [:eq, :n, 0],
          1,
        :true,
          [:*, :n, [:factorial, :factorial, [:+, :n, -1]]]
      ]
    ]

    expect(Blisp.eval([factorial, factorial, 5])).to eq 120
  end
end
