defmodule Aoc.Day10Test do
  use ExUnit.Case, async: false
  alias Aoc.Day10
  alias Aoc.Day10.Node

  describe "solve_p1/1" do
    test "example" do
      dbg Day10.solve_pt1("priv/day10_example.txt")
      # assert map_size(grid) == 25
    end
  end

  # This is some of the most important fundamental logic to the whole thing...
  describe "open/2" do
    test "foo" do
      start = %Node{x: 1, y: 1, symbol: "S"}
      north = %Node{x: 1, y: 0, symbol: "L"}
      refute Day10.open?(start, north)
    end
  end
end
