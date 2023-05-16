defmodule MorphTest do
  use ExUnit.Case
  doctest Morph

  test "greets the world" do
    assert Morph.hello() == :world
  end
end
