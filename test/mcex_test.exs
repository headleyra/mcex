defmodule McexTest do
  use ExUnit.Case
  doctest Mcex

  test "greets the world" do
    assert Mcex.hello() == :world
  end
end
